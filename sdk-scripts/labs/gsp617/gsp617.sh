
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp617

bq mk --project_id=$PROJECT_ID bq_logs

./task6.sh &

bq query --project_id=$PROJECT_ID \
    --use_legacy_sql=false "SELECT current_date()"

gcloud logging sinks create JobComplete \
    bigquery.googleapis.com/projects/$PROJECT_ID/datasets/bq_logs \
    --project $PROJECT_ID \
    --log-filter='resource.type="bigquery_resource" AND protoPayload.methodName="jobservice.jobcompleted"' &

bq query --project_id=$PROJECT_ID \
    --location=us \
    --use_legacy_sql=false \
    --use_cache=false '
SELECT fullName, AVG(CL.numberOfYears) avgyears
FROM `qwiklabs-resources.qlbqsamples.persons_living`, UNNEST(citiesLived) as CL
GROUP BY fullName
' &

bq query --project_id=$PROJECT_ID \
    --location=us \
    --use_legacy_sql=false \
    --use_cache=false '
select month, avg(mean_temp) as avgtemp from `qwiklabs-resources.qlweather_geo.gsod`
 where station_number = 947680
 and year = 2010
 group by month
 order by month
' &

bq query --project_id=$PROJECT_ID \
    --location=us \
    --use_legacy_sql=false \
    --use_cache=false \
'
select CONCAT(departure_airport, "-", arrival_airport) as route, count(*) as numberflights
 from `bigquery-samples.airline_ontime_data.airline_id_codes` ac,
 `qwiklabs-resources.qlairline_ontime_data.flights` fl
 where ac.code = fl.airline_code
 and regexp_contains(ac.airline ,  r"Alaska")
 group by 1
 order by 2 desc
 LIMIT 10
' & wait

# sleep 360

# bq query --project_id=$PROJECT_ID \
#     --location=us \
#     --use_legacy_sql=false \
#     --use_cache=false \
# '
# SELECT fullName, AVG(CL.numberOfYears) avgyears
#  FROM `qwiklabs-resources.qlbqsamples.persons_living`, UNNEST(citiesLived) as CL
#  GROUP BY fullName
# ' &

# bq query --project_id=$PROJECT_ID \
#     --location=us \
#     --use_legacy_sql=false \
#     --use_cache=false \
# '
# select month, avg(mean_temp) as avgtemp from `qwiklabs-resources.qlweather_geo.gsod`
#  where station_number = 947680
#  and year = 2010
#  group by month
#  order by month
# ' &

# bq query --project_id=$PROJECT_ID \
#     --location=us \
#     --use_legacy_sql=false \
#     --use_cache=false \
# '
# select CONCAT(departure_airport, "-", arrival_airport) as route, count(*) as numberflights
#  from `bigquery-samples.airline_ontime_data.airline_id_codes` ac,
#  `qwiklabs-resources.qlairline_ontime_data.flights` fl
#  where ac.code = fl.airline_code
#  and regexp_contains(ac.airline ,  r"Alaska")
#  group by 1
#  order by 2 desc
#  LIMIT 10
# ' 



echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#