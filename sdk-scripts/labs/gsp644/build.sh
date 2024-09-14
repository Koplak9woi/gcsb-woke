cd ./source

gcloud builds submit \
    --project $PROJECT_ID \
    --tag gcr.io/$PROJECT_ID/pdf-converter:1.0 &

gcloud builds submit \
    --project $PROJECT_ID \
    --tag gcr.io/$PROJECT_ID/pdf-converter:2.0 & wait