cd ./code/cloud-run/create-thumbnail

gcloud run deploy ${THUMBNAIL_SERVICE_NAME} \
    --image ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${THUMBNAIL_SERVICE_NAME} \
    --no-allow-unauthenticated \
    --memory=1Gi \
    --platform managed \
    --region $REGION \
    --max-instances=1 \
    --update-env-vars GENERATED_BUCKET=${GENERATED_BUCKET}
