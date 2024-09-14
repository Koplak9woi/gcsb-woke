#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp650/source

create_topic(){
    gcloud beta pubsub topics create new-lab-report --project $PROJECT_ID

    gcloud beta pubsub subscriptions create email-service-sub \
        --topic new-lab-report \
        --project $PROJECT_ID
}

create_topic &

gcloud iam service-accounts create pubsub-cloud-run-invoker \
    --display-name "PubSub Cloud Run Invoker" \
    --project $PROJECT_ID &

gcloud builds submit \
    --project $PROJECT_ID \
    --tag gcr.io/$PROJECT_ID/lab-report-service &
  
gcloud run deploy lab-report-service \
    --image aguzztn54/hello-nodejs \
    --platform managed \
    --region $REGION \
    --project $PROJECT_ID \
    --allow-unauthenticated \
    --max-instances=1 &

gcloud builds submit \
    --project $PROJECT_ID \
    --tag gcr.io/$PROJECT_ID/email-service &
  
gcloud run deploy email-service \
    --image aguzztn54/hello-nodejs \
    --platform managed \
    --region $REGION \
    --project $PROJECT_ID \
    --allow-unauthenticated \
    --max-instances=1 &

gcloud builds submit \
    --project $PROJECT_ID \
    --tag gcr.io/$PROJECT_ID/sms-service &
  
gcloud run deploy sms-service \
    --image aguzztn54/hello-nodejs \
    --platform managed \
    --region $REGION \
    --project $PROJECT_ID \
    --allow-unauthenticated \
    --max-instances=1 & wait

    
echo "${BG_GREEN}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#