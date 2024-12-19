
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if gcloud services enable dataplex.googleapis.com datacatalog.googleapis.com --project $PROJECT_ID; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done


gcloud data-catalog tag-templates create protected_data_template \
    --location=$REGION \
    --project $PROJECT_ID \
    --field=id=protected_data_flag,display-name="Protected Data Flag",type='enum(YES|NO)' \
    --display-name="Protected Data Template" &

gcloud dataplex lakes create orders-lake \
  --location=$REGION \
  --project $PROJECT_ID \
  --display-name="Orders Lake"

gcloud dataplex zones create customer-curated-zone \
    --location=$REGION \
    --project $PROJECT_ID \
    --lake=orders-lake \
    --display-name="Customer Curated Zone" \
    --resource-location-type=SINGLE_REGION \
    --type=CURATED \
    --discovery-enabled \
    --discovery-schedule="0 * * * *"

gcloud dataplex assets create customer-details-dataset \
    --location=$REGION \
    --project $PROJECT_ID \
    --lake=orders-lake \
    --zone=customer-curated-zone \
    --display-name="Customer Details Dataset" \
    --resource-type=BIGQUERY_DATASET \
    --resource-name=projects/$PROJECT_ID/datasets/customers \
    --discovery-enabled

echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}"https://console.cloud.google.com/dataplex/search?project=$PROJECT_ID&qSystems=DATAPLEX""${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#