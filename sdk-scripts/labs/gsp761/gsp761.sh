#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp761/source

# gcloud services enable cloudbuild.googleapis.com run.googleapis.com

gcloud firestore databases create --location nam5 --project $PROJECT_ID &

gcloud run deploy rest-api \
    --image aguzztn54/hello-nodejs \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --max-instances=2 \
    --project $PROJECT_ID &

gcloud builds submit \
    --tag gcr.io/$PROJECT_ID/rest-api:0.1 \
    --project $PROJECT_ID &
    
gcloud builds submit \
    --tag gcr.io/$PROJECT_ID/rest-api:0.2 \
    --project $PROJECT_ID & wait


echo "${BG_GREEN}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#