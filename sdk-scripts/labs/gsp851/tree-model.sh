bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
CREATE MODEL \`soccer.xg_logistic_reg_model\`
OPTIONS(
  model_type = 'LOGISTIC_REG',
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
 /* Includes both "open play" & free kick shots (including penalties) */
 (
   eventName = 'Shot' OR
   (eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
 )
;
"

# bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
# SELECT
#  *
# FROM
#  ML.PREDICT(
#    MODEL \`soccer.xg_logistic_reg_model\`,
#    (
#      SELECT
#        Events.subEventName AS shotType,

#        /* 101 is known Tag for 'goals' from goals table */
#        (101 IN UNNEST(Events.tags.id)) AS isGoal,

#        \`soccer.GetShotDistanceToGoal\`(Events.positions[ORDINAL(1)].x,
#            Events.positions[ORDINAL(1)].y) AS shotDistance,

#        \`soccer.GetShotAngleToGoal\`(Events.positions[ORDINAL(1)].x,
#            Events.positions[ORDINAL(1)].y) AS shotAngle

#      FROM
#        \`soccer.events\` Events

#      LEFT JOIN
#        \`soccer.matches\` Matches ON
#            Events.matchId = Matches.wyId

#      LEFT JOIN
#        \`soccer.competitions\` Competitions ON
#            Matches.competitionId = Competitions.wyId

#      WHERE
#        /* Look only at World Cup matches for model predictions */
#        Competitions.name = 'World Cup' AND
#        /* Includes both "open play" & free kick shots (including penalties) */
#        (
#            eventName = 'Shot' OR
#            (eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
#        )
#    )
#  )
# " &

# bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
# SELECT
#  predicted_isGoal_probs[ORDINAL(1)].prob AS predictedGoalProb,
#  * EXCEPT (predicted_isGoal, predicted_isGoal_probs),

# FROM
#  ML.PREDICT(
#    MODEL \`soccer.xg_logistic_reg_model\`,
#    (
#      SELECT
#        Events.playerId,
#        (Players.firstName || ' ' || Players.lastName) AS playerName,

#        Teams.name AS teamName,
#        CAST(Matches.dateutc AS DATE) AS matchDate,
#        Matches.label AS match,

#      /* Convert match period and event seconds to minute of match */
#        CAST((CASE
#          WHEN Events.matchPeriod = '1H' THEN 0
#          WHEN Events.matchPeriod = '2H' THEN 45
#          WHEN Events.matchPeriod = 'E1' THEN 90
#          WHEN Events.matchPeriod = 'E2' THEN 105
#          ELSE 120
#          END) +
#          CEILING(Events.eventSec / 60) AS INT64)
#          AS matchMinute,

#        Events.subEventName AS shotType,

#        /* 101 is known Tag for 'goals' from goals table */
#        (101 IN UNNEST(Events.tags.id)) AS isGoal,

#        \`soccer.GetShotDistanceToGoal\`(Events.positions[ORDINAL(1)].x,
#            Events.positions[ORDINAL(1)].y) AS shotDistance,

#        \`soccer.GetShotAngleToGoal\`(Events.positions[ORDINAL(1)].x,
#            Events.positions[ORDINAL(1)].y) AS shotAngle

#      FROM
#        \`soccer.events\` Events

#      LEFT JOIN
#        \`soccer.matches\` Matches ON
#            Events.matchId = Matches.wyId

#      LEFT JOIN
#        \`soccer.competitions\` Competitions ON
#            Matches.competitionId = Competitions.wyId

#      LEFT JOIN
#        \`soccer.players\` Players ON
#            Events.playerId = Players.wyId

#      LEFT JOIN
#        \`soccer.teams\` Teams ON
#            Events.teamId = Teams.wyId

#      WHERE
#        /* Look only at World Cup matches to apply model */
#        Competitions.name = 'World Cup' AND
#        /* Includes both "open play" & free kick shots (but not penalties) */
#        (
#          eventName = 'Shot' OR
#          (eventName = 'Free Kick' AND subEventName IN ('Free kick shot'))
#        ) AND
#        /* Filter only to goals scored */
#        (101 IN UNNEST(Events.tags.id))
#    )
#  )

# ORDER BY
#   predictedgoalProb
# " &


# bq query --project_id=$PROJECT_ID --use_legacy_sql=false "
# SELECT
#  *
# FROM
#  ML.WEIGHTS(MODEL soccer.xg_logistic_reg_model)
# ;
# "