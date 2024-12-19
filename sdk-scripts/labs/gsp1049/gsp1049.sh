
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

./insert.sh &

cat > spanner/manifest.json <<EOF_END
{
  "tables": [
      {
          "table_name": "Customer",
          "file_patterns": [
              "gs://$PROJECT_ID/spanner/data.csv"
          ],
          "columns": [
              {"column_name" : "CustomerId", "type_name" : "STRING" },
              {"column_name" : "Name", "type_name" : "STRING" },
              {"column_name" : "Location", "type_name" : "STRING" }
          ]
      }
  ]
}
EOF_END

gsutil mb -p $PROJECT_ID gs://$PROJECT_ID
gsutil cp spanner/emptyfile gs://$PROJECT_ID/tmp/emptyfile &
gsutil -m cp -r spanner gs://$PROJECT_ID/

gcloud services disable dataflow.googleapis.com --project $PROJECT_ID --force
gcloud services enable dataflow.googleapis.com --project $PROJECT_ID 

gcloud dataflow jobs run spanner-load \
    --project $PROJECT_ID \
    --gcs-location gs://$PROJECT_ID/spanner/template.json \
    --region us-west1 \
    --staging-location gs://$PROJECT_ID/tmp/ \
    --parameters instanceId=banking-instance,databaseId=banking-db,importManifest=gs://$PROJECT_ID/spanner/manifest.json

gcloud dataflow jobs run spanner-load \
    --project $PROJECT_ID \
    --gcs-location gs://dataflow-templates-us-central1/latest/Word_Count \
    --region us-central1 \
    --staging-location gs://$PROJECT_ID/tmp/ \
    --parameters inputFile=gs://$PROJECT_ID/spanner/manifest.json,output=gs://$PROJECT_ID

gcloud dataflow flex-template run tes-lagi \
    --project $PROJECT_ID \
    --template-file-gcs-location gs://dataflow-templates-us-west1/latest/flex/Yaml_Template \
    --region us-west1

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#