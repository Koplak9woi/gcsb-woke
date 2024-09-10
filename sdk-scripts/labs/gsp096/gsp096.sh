
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

gcloud pubsub topics create myTopic --project $PROJECT_ID

gcloud pubsub subscriptions create MySub --topic myTopic --project $PROJECT_ID

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#