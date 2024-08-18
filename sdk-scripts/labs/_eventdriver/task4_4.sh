cd ./code/cloud-run/delete-image

gcloud run deploy delete-image \
    --source . \
    --no-allow-unauthenticated \
    --max-instances=1 \
    --platform managed \
    --region $REGION \
    --update-env-vars GENERATED_BUCKET=${GENERATED_BUCKET}