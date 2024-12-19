
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

export REGION="${ZONE%-*}"

export KEY_1=$(echo $STEP_1 | grep -oP '(?<=e5\\">).*?(?=<\/mark)' | head -n1)
export VALUE_1=$(echo $STEP_1 | grep -oP '(?<=e5\\">).*?(?=<\/mark)' | tail -n1)

gcloud alpha dataplex lakes create customer-lake \
	--display-name="Customer-Lake" \
	--location=$REGION \
	--project $PROJECT_ID \
	--labels="key_1=$KEY_1,value_1=$VALUE_1"

gcloud dataplex zones create public-zone \
    --lake=customer-lake \
    --location=$REGION \
	--project $PROJECT_ID \
    --type=RAW \
    --resource-location-type=SINGLE_REGION \
    --display-name="Public-Zone"

gcloud dataplex environments create dataplex-lake-env \
    --project=$PROJECT_ID \
    --location=$REGION \
    --lake=customer-lake \
    --compute-node-count 3 \
    --compute-max-node-count 3 \
    --os-image-version=1.0 &

gcloud dataplex assets create customer-raw-data \
	--location=$REGION \
	--project $PROJECT_ID \
	--lake=customer-lake --zone=public-zone \
	--resource-type=STORAGE_BUCKET \
	--resource-name=projects/$PROJECT_ID/buckets/$PROJECT_ID-customer-bucket \
	--discovery-enabled \
	--display-name="Customer Raw Data" &

gcloud dataplex assets create customer-reference-data \
	--location=$REGION \
	--project $PROJECT_ID \
	--lake=customer-lake --zone=public-zone \
	--resource-type=BIGQUERY_DATASET \
	--resource-name=projects/$PROJECT_ID/datasets/customer_reference_data \
	--display-name="Customer Reference Data" &

gcloud data-catalog tag-templates create customer_data_tag_template \
    --location=$REGION \
    --project $PROJECT_ID \
    --field=id=data_owner,display-name="Data Owner",type=string \
    --field=id=pii_data,display-name="PII Data",type='enum(YES|NO)' \
    --display-name="Customer Data Tag Template"

cat > tag.json <<EOF_END
{
  "data_owner": "Agus",
  "pii_data": "YES"
}
EOF_END

ENTRY_NAME=$(gcloud data-catalog entries lookup "//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customer_reference_data/tables/us-states" --project $PROJECT_ID --format="value(name)")

gcloud data-catalog tags create --entry=${ENTRY_NAME} \
    --tag-template=customer_data_tag_template \
    --tag-template-location=$REGION \
    --tag-file=tag.json \
    --project $PROJECT_ID &

TOKEN=$(gcloud auth print-access-token --project $PROJECT_ID)
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
  "asset": "'$PROJECT_ID'.'$REGION'.customer-lake.public-zone.customer-raw-data",
  "dataPath": "gs://'$PROJECT_ID'-customer-bucket",
  "displayName": "My Entity",
  "format": {
    "csv": {
      "encoding": "UTF-8",
      "delimiter": ",",
      "headerRows": 0 
    }
  },
  "id": "public_table",
  "schema": {
    "userManaged": false 
  } 
}' \
"https://dataplex.googleapis.com/v1/$PROJECT_ID/$REGION/lakes/public-zone/entities"

echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}"https://console.cloud.google.com/dataplex/lakes/customer-lake/zones/public-zone/create-entity;location=$REGION?project=$PROJECT_ID ""${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#