gcloud run deploy pdf-converter \
    --image aguzztn54/hello-nodejs \
    --platform managed \
    --region $REGION \
    --project $PROJECT_ID \
    --no-allow-unauthenticated \
    --max-instances=1

gcloud run deploy pdf-converter \
    --image aguzztn54/hello-nodejs \
    --platform managed \
    --region $REGION \
    --project $PROJECT_ID \
    --memory=2Gi \
    --no-allow-unauthenticated \
    --max-instances=1 \
    --set-env-vars PDF_BUCKET=$PROJECT_ID-processed