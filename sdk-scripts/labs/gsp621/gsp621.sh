#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp621

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
'SELECT * FROM `billing_dataset.enterprise_billing` WHERE Cost > 0' &

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
'SELECT
 project.name as Project_Name,
 service.description as Service,
 location.country as Country,
 cost as Cost
FROM `billing_dataset.enterprise_billing`;' &

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
'SELECT project.id, count(*) as count from `billing_dataset.enterprise_billing` GROUP BY project.id' &

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
'SELECT ROUND(SUM(cost),2) as Cost, project.name from `billing_dataset.enterprise_billing` GROUP BY project.name' &

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"SELECT CONCAT(service.description, ' : ',sku.description) as Line_Item FROM \`billing_dataset.enterprise_billing\` GROUP BY 1" &

bq query --project_id=$PROJECT_ID --use_legacy_sql=false \
"SELECT CONCAT(service.description, ' : ',sku.description) as Line_Item, Count(*) as NUM FROM \`billing_dataset.enterprise_billing\` GROUP BY CONCAT(service.description, ' : ',sku.description)" & wait


echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#