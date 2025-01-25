# #---------DO NOT CHANGE ZONE----
ZONE=us-central1-b

REGION=${ZONE::-2}


#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp646



# export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
# export region=$REGION
# WORKDIR=$(pwd)
export REGION="${ZONE%-*}"

./task1_5-6.sh &

export USED_IP=used-ip-address
export UNUSED_IP=unused-ip-address

gcloud compute addresses create $USED_IP --project=$PROJECT_ID --region=$REGION &

gcloud compute addresses create $UNUSED_IP --project=$PROJECT_ID --region=$REGION & wait

export USED_IP_ADDRESS=$(gcloud compute addresses describe $USED_IP \
    --project=$PROJECT_ID \
    --region=$REGION \
    --format=json | jq -r '.address')

gcloud compute instances create static-ip-instance \
    --zone=$ZONE \
    --project=$PROJECT_ID \
    --machine-type=e2-standard-2 \
    --subnet=default \
    --address=$USED_IP_ADDRESS

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#