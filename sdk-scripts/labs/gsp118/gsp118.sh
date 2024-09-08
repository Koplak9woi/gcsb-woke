
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

gcloud compute networks subnets create private-ad-zone-1 \
    --network $VPC_NAME \
    --range 10.1.0.0/24 \
    --region $REGION_1 \
    --project $PROJECT_ID &

gcloud compute networks subnets create private-ad-zone-2 \
    --network $VPC_NAME \
    --range 10.2.0.0/24 \
    --region $REGION_2 \
    --project $PROJECT_ID &

gcloud compute firewall-rules create allow-internal-ports-private-ad \
    --network $VPC_NAME \
    --allow tcp:1-65535,udp:1-65535,icmp \
    --source-ranges  10.1.0.0/24,10.2.0.0/24 \
    --project $PROJECT_ID &

gcloud compute firewall-rules create allow-rdp \
    --network $VPC_NAME \
    --allow tcp:3389 \
    --source-ranges 0.0.0.0/0 \
    --project $PROJECT_ID & wait

gcloud compute instances create ad-dc1 \
    --machine-type e2-standard-2 \
    --boot-disk-type pd-ssd \
    --boot-disk-size 50GB \
    --image-family windows-2016 \
    --image-project windows-cloud \
    --network $VPC_NAME \
    --zone $ZONE_1 --subnet private-ad-zone-1 \
    --private-network-ip=10.1.0.100  \
    --project $PROJECT_ID &

gcloud compute instances create ad-dc2 \
    --machine-type e2-standard-2 \
    --boot-disk-size 50GB \
    --boot-disk-type pd-ssd \
    --image-family windows-2016 \
    --image-project windows-cloud \
    --can-ip-forward \
    --network $VPC_NAME \
    --zone $ZONE_2 \
    --subnet private-ad-zone-2 \
    --private-network-ip=10.2.0.100 \
    --project $PROJECT_ID & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#