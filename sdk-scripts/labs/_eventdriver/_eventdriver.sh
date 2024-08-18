# Building Event-Driven Orchestration on Google Cloud
enable_lib(){
    gcloud services enable \
        workflows.googleapis.com \
        workflowexecutions.googleapis.com \
        eventarc.googleapis.com \
        tasks.googleapis.com \
        cloudscheduler.googleapis.com \
        storage.googleapis.com \
        vision.googleapis.com \
        run.googleapis.com \
        cloudfunctions.googleapis.com \
        firestore.googleapis.com \
        appengine.googleapis.com \
        cloudbuild.googleapis.com \
        artifactregistry.googleapis.com
}

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if enable_lib; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

export UPLOAD_BUCKET=uploaded-images-${PROJECT_ID}
export GENERATED_BUCKET=generated-images-${PROJECT_ID}

cd ./labs/_eventdriver
# ==================== TASK 1 =======================

gcloud storage buckets create gs://${UPLOAD_BUCKET} \
    --location=$REGION \
    --uniform-bucket-level-access &

gcloud storage buckets create gs://${GENERATED_BUCKET} \
    --location=$REGION \
    --uniform-bucket-level-access & wait

gcloud storage buckets add-iam-policy-binding gs://${UPLOAD_BUCKET} \
    --member=allUsers \
    --role=roles/storage.objectViewer &

gcloud storage buckets add-iam-policy-binding gs://${GENERATED_BUCKET} \
    --member=allUsers \
    --role=roles/storage.objectViewer & wait

#  ==================================  TASK 2 - 3 ================================
./task2.sh &
gcloud tasks queues create thumbnail-task-queue --location $REGION

#  ================================== TASK 4 ===============================
# git clone --depth=1 https://github.com/GoogleCloudPlatform/training-data-analyst

# ln -s ~/training-data-analyst/courses/orchestration-and-choreography/lab1 ./code

export REPO_NAME=image-app-repo
export THUMBNAIL_SERVICE_NAME=create-thumbnail
export COLLAGE_SERVICE_NAME=create-collage
export EXTRACT_FUNCTION_NAME=extract-image-metadata


./task4_1.sh & ./task4_2.sh & ./task4_3.sh & ./task4_4.sh &

#   ================================ TASK 5 ===============================

./task5.sh & wait

#   ================================== TASK 6  ================================

export WORKFLOWS_SA=workflows-sa
export WORKFLOW_NAME=image-add-workflow
export WORKFLOW_TRIGGER_SA=workflow-trigger-sa

./task6.sh &
#   ============================= TASK 7 ========================================

./task7.sh

#   ================================= TASK 8 ================================
export IMAGE_NAME=neon.jpg
gcloud storage cp ./code/images/${IMAGE_NAME} gs://${UPLOAD_BUCKET} &

# echo "uploaded image: https://storage.googleapis.com/${UPLOAD_BUCKET}/${IMAGE_NAME}"
# echo "generated image: https://storage.googleapis.com/${GENERATED_BUCKET}/${IMAGE_NAME}"
# echo "Listing of generated-images bucket:"

# gcloud storage ls gs://${GENERATED_BUCKET}

# ============================================ TASK 9 ===================================

gcloud storage cp ./code/images/alley.jpg gs://${UPLOAD_BUCKET} &

gcloud storage cp ./code/images/desktop.jpg gs://${UPLOAD_BUCKET} &

gcloud storage cp ./code/images/rainbow.jpg gs://${UPLOAD_BUCKET} &

gcloud storage cp ./code/images/vegas.jpg gs://${UPLOAD_BUCKET} 

./task9.sh &

# ========================= TASK 10 ==========================
export DELETE_TRIGGER_SA=delete-image-trigger-sa

export DELETE_SERVICE=delete-image

gcloud iam service-accounts create ${DELETE_TRIGGER_SA}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${DELETE_TRIGGER_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/eventarc.eventReceiver" &

gcloud run services add-iam-policy-binding ${DELETE_SERVICE} \
    --region=${REGION} \
    --member="serviceAccount:${DELETE_TRIGGER_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

  gcloud eventarc triggers create image-delete-trigger \
    --location=${REGION} \
    --destination-run-service $DELETE_SERVICE \
    --destination-run-path "/" \
    --event-filters="type=google.cloud.storage.object.v1.deleted" \
    --event-filters="bucket=${UPLOAD_BUCKET}" \
    --service-account="${DELETE_TRIGGER_SA}@${PROJECT_ID}.iam.gserviceaccount.com"