
# ============================ TASK 2 & 5 ===============================
cd ./functions
  
gcloud functions deploy temperature-converter \
    --gen2 \
    --runtime=nodejs20 \
    --region=$REGION \
    --source=. \
    --entry-point=convertTemp \
    --trigger-http \
    --allow-unauthenticated \
    --project $PROJECT_ID \
    --set-env-vars=TEMP_CONVERT_TO=ctof

