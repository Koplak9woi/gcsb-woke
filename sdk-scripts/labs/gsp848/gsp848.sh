#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

bq --location=us mk --dataset $PROJECT_ID:soccer


#task3
bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.competitions gs://spls/bq-soccer-analytics/competitions.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.matches gs://spls/bq-soccer-analytics/matches.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.teams gs://spls/bq-soccer-analytics/teams.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.players gs://spls/bq-soccer-analytics/players.json &

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:soccer.events gs://spls/bq-soccer-analytics/events.json &


# task 4

bq load --autodetect --source_format=CSV $PROJECT_ID:soccer.tags2name gs://spls/bq-soccer-analytics/tags2name.csv & wait

#task 6

bq query --use_legacy_sql=false \
"
SELECT
  (firstName || ' ' || lastName) AS player,
  birthArea.name AS birthArea,
  height
FROM
  \`soccer.players\`
WHERE
  role.name = 'Defender'
ORDER BY
  height DESC
LIMIT 5
" &

#task 7


bq query --use_legacy_sql=false \
"SELECT
  eventId,
  eventName,
  COUNT(id) AS numEvents
FROM
  \`soccer.events\`
GROUP BY
  eventId, eventName
ORDER BY
  numEvents DESC
"

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#