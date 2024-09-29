
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp118

export REGION_1="${ZONE_1%-*}"
export REGION_2="${ZONE_2%-*}"
export VPC_NAME=webappnet

gcloud compute networks create $VPC_NAME  \
    --description "VPC network to deploy Active Directory" \
    --subnet-mode custom \
    --project $PROJECT_ID

./vm1.sh &
./vm2.sh & 

gcloud compute firewall-rules create allow-internal-ports-private-ad \
    --network $VPC_NAME \
    --allow tcp:1-65535,udp:1-65535,icmp \
    --source-ranges 10.1.0.0/24,10.2.0.0/24 \
    --project $PROJECT_ID &

gcloud compute firewall-rules create allow-rdp \
    --network $VPC_NAME \
    --allow tcp:3389 \
    --source-ranges 0.0.0.0/0 \
    --project $PROJECT_ID & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#