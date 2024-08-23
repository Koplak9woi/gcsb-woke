cd ./terra

gcloud storage buckets create gs://$PROJECT_ID --location $REGION

gcloud storage cp *.html gs://$PROJECT_ID