cd ./code/cloud-run/create-thumbnail

gcloud artifacts repositories create ${REPO_NAME} \
    --location $REGION \
    --repository-format docker

gcloud builds submit . \
  --tag ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${THUMBNAIL_SERVICE_NAME}