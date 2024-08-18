cd ./code/cloud-run/create-collage

gcloud builds submit . \
    --tag ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${COLLAGE_SERVICE_NAME}

gcloud run deploy ${COLLAGE_SERVICE_NAME} \
    --image ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${COLLAGE_SERVICE_NAME} \
    --no-allow-unauthenticated \
    --memory=1Gi \
    --max-instances=1 \
    --platform managed \
    --region $REGION \
    --update-env-vars GENERATED_BUCKET=${GENERATED_BUCKET}