
bq mk fruit_store

bq mk --table --description "Table for fruit details" $PROJECT_ID:fruit_store.fruit_details

bq load --source_format=NEWLINE_DELIMITED_JSON --autodetect $PROJECT_ID:fruit_store.fruit_details gs://data-insights-course/labs/optimizing-for-performance/shopping_cart.json &

echo "${GREEN}${BOLD}Task 2. Practice working with arrays in SQL Completed ${RESET}" &

bq query --use_legacy_sql=false \
"
SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(DISTINCT v2ProductName) AS products_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT v2ProductName)) AS distinct_products_viewed,
  ARRAY_AGG(DISTINCT pageTitle) AS pages_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT pageTitle)) AS distinct_pages_viewed
  FROM \`data-to-insights.ecommerce.all_sessions\`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date
" &

echo "${GREEN}${BOLD}Task 3. Create your own arrays with ARRAY_AGG() Completed${RESET}" &

bq query --use_legacy_sql=false \
"
SELECT DISTINCT
  visitId,
  h.page.pageTitle
FROM \`bigquery-public-data.google_analytics_sample.ga_sessions_20170801\`,
UNNEST(hits) AS h
WHERE visitId = 1501570398
LIMIT 10
" &

echo "${GREEN}${BOLD}Task 4. Query tables containing arrays Completed${RESET}" & wait