#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

bq mk --project_id=$PROJECT_ID ecommerce

cd ./labs/gsp229/

./model2.sh & 

bq query --project_id=$PROJECT_ID --nouse_legacy_sql "
CREATE OR REPLACE MODEL \`ecommerce.classification_model\`
OPTIONS
  (
    model_type='logistic_reg',
    input_label_cols = ['will_buy_on_return_visit'],
    early_stop = true,
    MAX_ITERATIONS = 1,
    LEARN_RATE_STRATEGY = 'CONSTANT'
  )
AS

#standardSQL
SELECT
  * EXCEPT(fullVisitorId)
FROM

  # features
  (SELECT
    fullVisitorId,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS time_on_site
  FROM
    \`data-to-insights.ecommerce.web_analytics\`
  WHERE
    totals.newVisits = 1
    AND date = '20170430'
    AND device.isMobile = false
    AND totals.hits <= 2) # train on first 9 months
  JOIN
  (SELECT
    fullvisitorid,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
  FROM
      \`data-to-insights.ecommerce.web_analytics\`
  GROUP BY fullvisitorid)
  USING (fullVisitorId)"

bq query --project_id=$PROJECT_ID --nouse_legacy_sql '
SELECT
  roc_auc,
  CASE
    WHEN roc_auc > .9 THEN "good"
    WHEN roc_auc > .8 THEN "fair"
    WHEN roc_auc > .7 THEN "decent"
    WHEN roc_auc > .6 THEN "not great"
  ELSE "poor" END AS model_quality
FROM
  ML.EVALUATE(MODEL ecommerce.classification_model,  (
SELECT
  * EXCEPT(fullVisitorId)
FROM
  # features
  (SELECT
    fullVisitorId,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS time_on_site
  FROM
    `data-to-insights.ecommerce.web_analytics`
  WHERE
    totals.newVisits = 1
    AND date BETWEEN "20170501" AND "20170630") # eval on 2 months
  JOIN
  (SELECT
    fullvisitorid,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
  FROM
      `data-to-insights.ecommerce.web_analytics`
  GROUP BY fullvisitorid)
  USING (fullVisitorId)
));'

  
echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"
