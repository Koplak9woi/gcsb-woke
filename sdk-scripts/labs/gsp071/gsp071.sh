#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp071

bq show --project_id=$PROJECT_ID bigquery-public-data:samples.shakespeare

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
'SELECT
   word,
   SUM(word_count) AS count
 FROM
   `bigquery-public-data`.samples.shakespeare
 WHERE
   word LIKE "%raisin%"
 GROUP BY
   word'

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
'SELECT
   word
 FROM
   `bigquery-public-data`.samples.shakespeare
 WHERE
   word = "huzzah"'

bq mk --project_id=$PROJECT_ID babynames

# curl -L http://www.ssa.gov/OACT/babynames/names.zip --output $FOLDER/names.zip

# unzip $FOLDER/names.zip -d $FOLDER

bq load --project_id=$PROJECT_ID babynames.names2010 yob2010.txt name:string,gender:string,count:integer

bq query --project_id=$PROJECT_ID "SELECT name,count FROM babynames.names2010 WHERE gender = 'F' ORDER BY count DESC LIMIT 5"

bq query --project_id=$PROJECT_ID "SELECT name,count FROM babynames.names2010 WHERE gender = 'M' ORDER BY count ASC LIMIT 5"

yes | bq rm --project_id=$PROJECT_ID -r babynames

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#