export CLOUD_STORAGE_SA="$(gcloud storage service-agent)"

gcloud iam service-accounts create ${WORKFLOW_TRIGGER_SA}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${WORKFLOW_TRIGGER_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/workflows.invoker" 

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${WORKFLOW_TRIGGER_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/eventarc.eventReceiver" 

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${WORKFLOW_TRIGGER_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/eventarc.eventReceiver" 

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_STORAGE_SA}" \
    --role="roles/pubsub.publisher"

create_trigger(){
    gcloud eventarc triggers create image-add-trigger \
        --location=${REGION} \
        --destination-workflow=${WORKFLOW_NAME} \
        --destination-workflow-location=${REGION} \
        --event-filters="type=google.cloud.storage.object.v1.finalized" \
        --event-filters="bucket=${UPLOAD_BUCKET}" \
        --service-account="${WORKFLOW_TRIGGER_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
}

trigger_created=false
while [ "$trigger_created" = false ]; do
    if create_trigger; then
        echo "Eventarc Trigger Created"
        trigger_created=true
    else
        echo "Re-trying to create Eventarc Trigger..."
    fi
done