
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

gcloud compute instances create vm-premium \
    --zone=$ZONE \
    --project $PROJECT_ID \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM &

gcloud compute instances create vm-standard \
    --zone=$ZONE \
    --project $PROJECT_ID \
    --machine-type=e2-medium \
    --network-interface=network-tier=STANDARD

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#