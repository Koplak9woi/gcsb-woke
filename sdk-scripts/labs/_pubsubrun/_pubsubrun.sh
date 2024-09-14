
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

enable_lib(){
    gcloud services enable pubsub.googleapis.com --project $PROJECT_ID
    gcloud services disable pubsub.googleapis.com --force --project $PROJECT_ID
    gcloud services enable run.googleapis.com --project $PROJECT_ID
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

gcloud run deploy store-service \
    --image us-docker.pkg.dev/cloudrun/container/hello \
    --region $REGION \
    --project $PROJECT_ID \
    --allow-unauthenticated &

gcloud run deploy order-service \
    --image us-docker.pkg.dev/cloudrun/container/hello \
    --region $REGION \
    --project $PROJECT_ID \
    --no-allow-unauthenticated &

gcloud iam service-accounts create pubsub-cloud-run-invoker \
    --project $PROJECT_ID \
    --display-name "Order Initiator" &

gcloud pubsub topics create ORDER_PLACED --project $PROJECT_ID 

gcloud pubsub subscriptions create order-service-sub \
    --topic ORDER_PLACED \
    --project $PROJECT_ID & wait

# ======================= OPTIONAL =========================

gcloud run services add-iam-policy-binding order-service \
    --project $PROJECT_ID \
    --region $REGION \
    --member=serviceAccount:pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/run.invoker \
    --platform managed &

PROJECT_NUMBER=$(gcloud projects list \
    --filter="qwiklabs-gcp" \
    --format='value(PROJECT_NUMBER)')

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --project $PROJECT_ID \
    --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountTokenCreator &

ORDER_SERVICE_URL=$(gcloud run services describe order-service \
    --region $REGION \
    --project $PROJECT_ID \
    --format="value(status.address.url)")

gcloud pubsub subscriptions update order-service-sub \
    --project $PROJECT_ID \
    --push-endpoint=$ORDER_SERVICE_URL \
    --push-auth-service-account=pubsub-cloud-run-invoker@$PROJECT_ID.iam.gserviceaccount.com & wait

    
echo "${BG_GREEN}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#