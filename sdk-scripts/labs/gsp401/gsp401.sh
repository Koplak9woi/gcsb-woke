#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

gcloud services enable cloudscheduler.googleapis.com --project $PROJECT_ID

gcloud pubsub topics create cron-topic --project $PROJECT_ID

gcloud pubsub subscriptions create cron-sub --topic cron-topic --project $PROJECT_ID

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#