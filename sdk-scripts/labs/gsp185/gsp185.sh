#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp185

# gcloud app create --region $REGION --project $PROJECT_ID;

gcloud config set project $PROJECT_ID

gsutil mb gs://$PROJECT_ID-media
gsutil cp Google_Cloud_Storage_logo.png gs://$PROJECT_ID-media

gsutil rm -r gs://$PROJECT_ID-media
gsutil mb gs://$PROJECT_ID-media
gsutil cp Google_Cloud_Storage_logo.png gs://$PROJECT_ID-media

gsutil rm -r gs://$PROJECT_ID-media
gsutil mb gs://$PROJECT_ID-media
gsutil cp Google_Cloud_Storage_logo.png gs://$PROJECT_ID-media

gsutil rm -r gs://$PROJECT_ID-media
gsutil mb gs://$PROJECT_ID-media
gsutil rm -r gs://$PROJECT_ID-media
gsutil mb gs://$PROJECT_ID-media
gsutil rm -r gs://$PROJECT_ID-media
gsutil mb gs://$PROJECT_ID-media

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#