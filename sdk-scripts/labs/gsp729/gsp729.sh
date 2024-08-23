#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp729

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if gcloud services enable datacatalog.googleapis.com --project $PROJECT_ID; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

bq mk demo_dataset

bq cp bigquery-public-data:new_york_taxi_trips.tlc_yellow_trips_2018 $PROJECT_ID:demo_dataset.trips

gcloud data-catalog tag-templates create demo_tag_template \
    --location=$REGION \
    --display-name="Demo Tag Template" \
    --field=id=source_of_data_asset,display-name="Source of data asset",type=string,required=TRUE \
    --field=id=number_of_rows_in_data_asset,display-name="Number of rows in data asset",type=double \
    --field=id=has_pii,display-name="Has PII",type=bool \
    --field=id=pii_type,display-name="PII type",type='enum(Email|Social Security Number|None)'

ENTRY_NAME=$(gcloud data-catalog entries lookup '//bigquery.googleapis.com/projects/'$PROJECT_ID'/datasets/demo_dataset/tables/trips' --format="value(name)")

gcloud data-catalog tags create --entry=${ENTRY_NAME} \
    --tag-template=demo_tag_template --tag-template-location=$REGION --tag-file=tag_file.json

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#