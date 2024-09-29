#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

TASK4_START=$(date -d "$MONTH 01, 2020" "+%Y-%m-%d")
TASK4_END=$(date -d "$MONTH 30, 2020" "+%Y-%m-%d")

IFS=' to ' read -ra DATE_RANGE <<< "$RANGE"
LOOKER_START=${DATE_RANGE[0]}
LOOKER_END=${DATE_RANGE[2]}

# TASK1
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
SELECT sum(cumulative_confirmed) as total_cases_worldwide
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE date='$DATE'
" &

# TASK 2
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
WITH deaths_by_states AS (
    SELECT subregion1_name as state, sum(cumulative_deceased) as death_count
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name=\"United States of America\" and date='$DATE' and subregion1_name is NOT NULL
    GROUP BY subregion1_name
)
SELECT count(*) as count_of_states
FROM deaths_by_states
WHERE death_count > $TASK2_DEATH
" &

# TASK 5
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
SELECT date
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE country_name=\"Italy\" and cumulative_deceased > $TASK5_DEATH
ORDER BY date asc
LIMIT 1
" &

# TASK 6
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
WITH india_cases_by_date AS (
    SELECT date, SUM(cumulative_confirmed) AS cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name =\"India\" AND date BETWEEN '$TASK6_START' AND '$TASK6_END'
    GROUP BY date
    ORDER BY date ASC
), india_previous_day_comparison AS (
    SELECT date, cases, LAG(cases) OVER(ORDER BY date) AS previous_day, cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases
    FROM india_cases_by_date
)
SELECT count(*)
FROM india_previous_day_comparison
WHERE net_new_cases=0
" &

# TASK 7
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
WITH us_cases_by_date AS (
    SELECT date, SUM(cumulative_confirmed) AS cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name=\"United States of America\" AND date BETWEEN '2020-03-22' AND '2020-04-20'
    GROUP BY date
    ORDER BY date ASC
), us_previous_day_comparison AS (
    SELECT date, cases, LAG(cases) OVER(ORDER BY date) AS previous_day,
           cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases,
           (cases - LAG(cases) OVER(ORDER BY date))*100/LAG(cases) OVER(ORDER BY date) AS percentage_increase
    FROM us_cases_by_date
)
SELECT Date, cases AS Confirmed_Cases_On_Day, previous_day AS Confirmed_Cases_Previous_Day, percentage_increase AS Percentage_Increase_In_Cases
FROM us_previous_day_comparison
WHERE percentage_increase > $LIMIT
" &

# TASK 8
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
WITH cases_by_country AS (
  SELECT
    country_name AS country,
    sum(cumulative_confirmed) AS cases,
    sum(cumulative_recovered) AS recovered_cases
  FROM
    bigquery-public-data.covid19_open_data.covid19_open_data
  WHERE
    date = '2020-05-10'
  GROUP BY
    country_name
 )
, recovered_rate AS
(SELECT
  country, cases, recovered_cases,
  (recovered_cases * 100)/cases AS recovery_rate
FROM cases_by_country
)
SELECT country, cases AS confirmed_cases, recovered_cases, recovery_rate
FROM recovered_rate
WHERE cases > 50000
ORDER BY recovery_rate desc
LIMIT $LIMIT
" &

# TASK 9
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
WITH france_cases AS (
    SELECT date, SUM(cumulative_confirmed) AS total_cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name=\"France\" AND date IN ('2020-01-24', '$DATE')
    GROUP BY date
    ORDER BY date
), summary AS (
    SELECT total_cases AS first_day_cases, LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,
           DATE_DIFF(LEAD(date) OVER(ORDER BY date), date, day) AS days_diff
    FROM france_cases
    LIMIT 1
)
SELECT first_day_cases, last_day_cases, days_diff,
       POWER((last_day_cases/first_day_cases),(1/days_diff))-1 AS cdgr
FROM summary
" & 

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
SELECT date, SUM(cumulative_confirmed) AS country_cases,
       SUM(cumulative_deceased) AS country_deaths
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE date BETWEEN '$LOOKER_START' AND '$LOOKER_END'
  AND country_name =\"United States of America\"
GROUP BY date
" &

# TASK 3
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
SELECT * FROM (
    SELECT subregion1_name as state, sum(cumulative_confirmed) as total_confirmed_cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_code=\"US\" AND date='$DATE' AND subregion1_name is NOT NULL
    GROUP BY subregion1_name
    ORDER BY total_confirmed_cases DESC
)
WHERE total_confirmed_cases > $TASK3_CASES
"

# TASK 4
bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"
SELECT sum(cumulative_confirmed) as total_confirmed_cases,
       sum(cumulative_deceased) as total_deaths,
       (sum(cumulative_deceased)/sum(cumulative_confirmed))*100 as case_fatality_ratio
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE country_name=\"Italy\" AND date BETWEEN '$TASK4_START' and '$TASK4_END'
" & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
