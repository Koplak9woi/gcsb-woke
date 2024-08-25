#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp851

bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
CREATE FUNCTION \`soccer.GetShotDistanceToGoal\`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 /* Translate 0-100 (x,y) coordinate-based distances to absolute positions
 using "average" field dimensions of 105x68 before combining in 2D dist calc */
 SQRT(
   POW((100 - x) * 105/100, 2) +
   POW((50 - y) * 68/100, 2)
   )
 );
" &


bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
CREATE FUNCTION \`soccer.GetShotAngleToGoal\`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 SAFE.ACOS(
   /* Have to translate 0-100 (x,y) coordinates to absolute positions using
   "average" field dimensions of 105x68 before using in various distance calcs */
   SAFE_DIVIDE(
     ( /* Squared distance between shot and 1 post, in meters */
       (POW(105 - (x * 105/100), 2) + POW(34 + (7.32/2) - (y * 68/100), 2)) +
       /* Squared distance between shot and other post, in meters */
       (POW(105 - (x * 105/100), 2) + POW(34 - (7.32/2) - (y * 68/100), 2)) -
       /* Squared length of goal opening, in meters */
       POW(7.32, 2)
     ),
     (2 *
       /* Distance between shot and 1 post, in meters */
       SQRT(POW(105 - (x * 105/100), 2) + POW(34 + 7.32/2 - (y * 68/100), 2)) *
       /* Distance between shot and other post, in meters */
       SQRT(POW(105 - (x * 105/100), 2) + POW(34 - 7.32/2 - (y * 68/100), 2))
     )
    )
  /* Translate radians to degrees */
  ) * 180 / ACOS(-1)
 )
;
" &


./tree-model.sh &

bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
CREATE MODEL \`soccer.xg_boosted_tree_model\`
OPTIONS(
    model_type = 'BOOSTED_TREE_CLASSIFIER',
    input_label_cols = ['isGoal'],
    early_stop = true,
    MAX_ITERATIONS = 1,
    LEARN_RATE_STRATEGY = 'CONSTANT',
    LEARN_RATE = 0.5
 ) AS

SELECT
 Events.subEventName AS shotType,
 /* 101 is known Tag for 'goals' from goals table */
 (101 IN UNNEST(Events.tags.id)) AS isGoal,
  \`soccer.GetShotDistanceToGoal\`(Events.positions[ORDINAL(1)].x,
   Events.positions[ORDINAL(1)].y) AS shotDistance,

 \`soccer.GetShotAngleToGoal\`(Events.positions[ORDINAL(1)].x,
   Events.positions[ORDINAL(1)].y) AS shotAngle

FROM
 \`soccer.events\` Events

LEFT JOIN
 \`soccer.matches\` Matches ON
   Events.matchId = Matches.wyId

LEFT JOIN
 \`soccer.competitions\` Competitions ON
   Matches.competitionId = Competitions.wyId

WHERE
 /* Filter out World Cup matches for model fitting purposes */
 Competitions.name != 'World Cup' AND
 gameweek = 1 AND
 matchPeriod = "1H" AND
 /* Includes both "open play" & free kick shots (including penalties) */
 (
   eventName = 'Shot' OR
   (eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
 )
;
" & wait



echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#