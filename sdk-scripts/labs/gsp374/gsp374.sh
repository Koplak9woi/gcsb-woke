#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

bq load --source_format=NEWLINE_DELIMITED_JSON --autodetect $PROJECT_ID:soccer.$EVENT gs://spls/bq-soccer-analytics/events.json &

bq load --source_format=CSV --autodetect $PROJECT_ID:soccer.$TABLE gs://spls/bq-soccer-analytics/tags2name.csv &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.competitions gs://spls/bq-soccer-analytics/competitions.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.matches gs://spls/bq-soccer-analytics/matches.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.teams gs://spls/bq-soccer-analytics/teams.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.players gs://spls/bq-soccer-analytics/players.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.events gs://spls/bq-soccer-analytics/events.json & wait

bq query --use_legacy_sql=false \
"
SELECT
playerId,
(Players.firstName || ' ' || Players.lastName) AS playerName,
COUNT(id) AS numPKAtt,
SUM(IF(101 IN UNNEST(tags.id), 1, 0)) AS numPKGoals,
SAFE_DIVIDE(
SUM(IF(101 IN UNNEST(tags.id), 1, 0)),
COUNT(id)
) AS PKSuccessRate
FROM
\`soccer.$EVENT\` Events
LEFT JOIN
\`soccer.players\` Players ON
Events.playerId = Players.wyId
WHERE
eventName = 'Free Kick' AND
subEventName = 'Penalty'
GROUP BY
playerId, playerName
HAVING
numPkAtt >= 5
ORDER BY
PKSuccessRate DESC, numPKAtt DESC
"

bq query --use_legacy_sql=false \
"
WITH
Shots AS
(
SELECT
*,
/* 101 is known Tag for 'goals' from goals table */
(101 IN UNNEST(tags.id)) AS isGoal,
/* Translate 0-100 (x,y) coordinate-based distances to absolute positions
using \"average\" field dimensions of 105x68 before combining in 2D dist calc */
SQRT(
POW(
  (100 - positions[ORDINAL(1)].x) * $X_GOAL/$Y_GOAL,
  2) +
POW(
  (60 - positions[ORDINAL(1)].y) * $X_AXIS/$Y_AXIS,
  2)
 ) AS shotDistance
FROM
\`soccer.$EVENT\`
WHERE
/* Includes both \"open play\" & free kick shots (including penalties) */
eventName = 'Shot' OR
(eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
)
SELECT
ROUND(shotDistance, 0) AS ShotDistRound0,
COUNT(*) AS numShots,
SUM(IF(isGoal, 1, 0)) AS numGoals,
AVG(IF(isGoal, 1, 0)) AS goalPct
FROM
Shots
WHERE
shotDistance <= 50
GROUP BY
ShotDistRound0
ORDER BY
ShotDistRound0
"

bq query --use_legacy_sql=false \
"
CREATE MODEL \`$MODEL\`
OPTIONS(
model_type = 'LOGISTIC_REG',
input_label_cols = ['isGoal']
) AS
SELECT
Events.subEventName AS shotType,
/* 101 is known Tag for 'goals' from goals table */
(101 IN UNNEST(Events.tags.id)) AS isGoal,
\`$FUNC_1\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotDistance,
\`$FUNC_2\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotAngle
FROM
\`soccer.$EVENT\` Events
LEFT JOIN
\`soccer.matches\` Matches ON
Events.matchId = Matches.wyId
LEFT JOIN
\`soccer.competitions\` Competitions ON
Matches.competitionId = Competitions.wyId
WHERE
/* Filter out World Cup matches for model fitting purposes */
Competitions.name != 'World Cup' AND
/* Includes both \"open play\" & free kick shots (including penalties) */
(
eventName = 'Shot' OR
(eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
) AND
\`$FUNC_2\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) IS NOT NULL
;
"

bq query --use_legacy_sql=false \
"
SELECT
predicted_isGoal_probs[ORDINAL(1)].prob AS predictedGoalProb,
* EXCEPT (predicted_isGoal, predicted_isGoal_probs),
FROM
ML.PREDICT(
MODEL \`$MODEL\`, 
(
 SELECT
   Events.playerId,
   (Players.firstName || ' ' || Players.lastName) AS playerName,
   Teams.name AS teamName,
   CAST(Matches.dateutc AS DATE) AS matchDate,
   Matches.label AS match,
 /* Convert match period and event seconds to minute of match */
   CAST((CASE
     WHEN Events.matchPeriod = '1H' THEN 0
     WHEN Events.matchPeriod = '2H' THEN 45
     WHEN Events.matchPeriod = 'E1' THEN 90
     WHEN Events.matchPeriod = 'E2' THEN 105
     ELSE 120
     END) +
     CEILING(Events.eventSec / 60) AS INT64)
     AS matchMinute,
   Events.subEventName AS shotType,
   /* 101 is known Tag for 'goals' from goals table */
   (101 IN UNNEST(Events.tags.id)) AS isGoal,
 
   \`soccer.$FUNC_1\`(Events.positions[ORDINAL(1)].x,
       Events.positions[ORDINAL(1)].y) AS shotDistance,
   \`soccer.$FUNC_2\`(Events.positions[ORDINAL(1)].x,
       Events.positions[ORDINAL(1)].y) AS shotAngle
 FROM
   \`soccer.$EVENT\` Events
 LEFT JOIN
   \`soccer.matches\` Matches ON
       Events.matchId = Matches.wyId
 LEFT JOIN
   \`soccer.competitions\` Competitions ON
       Matches.competitionId = Competitions.wyId
 LEFT JOIN
   \`soccer.players\` Players ON
       Events.playerId = Players.wyId
 LEFT JOIN
   \`soccer.teams\` Teams ON
       Events.teamId = Teams.wyId
 WHERE
   /* Look only at World Cup matches to apply model */
   Competitions.name = 'World Cup' AND
   /* Includes both \"open play\" & free kick shots (but not penalties) */
   (
     eventName = 'Shot' OR
     (eventName = 'Free Kick' AND subEventName IN ('Free kick shot'))
   ) AND
   /* Filter only to goals scored */
   (101 IN UNNEST(Events.tags.id))
)
)
ORDER BY
predictedgoalProb
"

bq query --use_legacy_sql=false \
"
CREATE FUNCTION \`$FUNC_1\`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 SQRT(
   POW(($X_GOAL - x) * $X_AXIS/100, 2) +
   POW(($Y_GOAL - y) * $Y_AXIS/100, 2)
   )
 );
" &

bq query --use_legacy_sql=false \
"
CREATE FUNCTION \`$FUNC_2\`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 SAFE.ACOS(
   SAFE_DIVIDE(
     ( /* Squared distance between shot and 1 post, in meters */
       (POW($X_AXIS - (x * $X_AXIS/100), 2) + POW($Y_HALF + (7.32/2) - (y * $Y_AXIS/100), 2)) +
       /* Squared distance between shot and other post, in meters */
       (POW($X_AXIS - (x * $X_AXIS/100), 2) + POW($Y_HALF - (7.32/2) - (y * $Y_AXIS/100), 2)) -
       /* Squared length of goal opening, in meters */
       POW(7.32, 2)
     ),
     (2 *
       /* Distance between shot and 1 post, in meters */
       SQRT(POW($X_AXIS - (x * $X_AXIS/100), 2) + POW($Y_HALF + 7.32/2 - (y * $Y_AXIS/100), 2)) *
       /* Distance between shot and other post, in meters */
       SQRT(POW($X_AXIS - (x * $X_AXIS/100), 2) + POW($Y_HALF - 7.32/2 - (y * $Y_AXIS/100), 2))
     )
    )
  /* Translate radians to degrees */
  ) * 180 / ACOS(-1)
 )
;
" & wait


echo "${YELLOW}${BOLD}NOW${RESET}" "${WHITE}${BOLD}FOLLOW${RESET}" "${GREEN}${BOLD}VIDEO'S INSTRUCTIONS${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#