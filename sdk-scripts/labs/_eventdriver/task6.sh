gcloud iam service-accounts create ${WORKFLOWS_SA}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/datastore.user"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/cloudtasks.enqueuer"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

gcloud functions add-iam-policy-binding ${EXTRACT_FUNCTION_NAME} \
    --member="serviceAccount:${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/cloudfunctions.invoker"

gcloud run services add-iam-policy-binding ${THUMBNAIL_SERVICE_NAME} \
    --region=${REGION} \
    --member="serviceAccount:${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/run.viewer"

gcloud run services add-iam-policy-binding ${THUMBNAIL_SERVICE_NAME} \
    --region=${REGION} \
    --member="serviceAccount:${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/run.invoker"


cd ./code/workflows

gcloud workflows deploy ${WORKFLOW_NAME} \
    --source=${WORKFLOW_NAME}.yaml \
    --location=${REGION} \
    --service-account="${WORKFLOWS_SA}@${PROJECT_ID}.iam.gserviceaccount.com"