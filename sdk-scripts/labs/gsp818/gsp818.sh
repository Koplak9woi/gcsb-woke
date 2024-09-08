
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp818

gcloud compute networks create vpc-cluster \
    --bgp-routing-mode=regional \
    --subnet-mode=custom \
    --project $PROJECT_ID &

gcloud compute networks create vpc-management \
    --bgp-routing-mode=regional \
    --subnet-mode=custom \
    --project $PROJECT_ID &

gcloud compute networks create vpc-prod \
    --bgp-routing-mode=regional \
    --subnet-mode=custom \
    --project $PROJECT_ID &

gcloud compute networks create vpc-qa \
    --bgp-routing-mode=regional \
    --subnet-mode=custom \
    --project $PROJECT_ID & wait

gcloud compute networks subnets create cluster \
    --network=vpc-cluster \
    --range=192.168.110.0/24 \
    --region=$REGION \
    --enable-private-ip-google-access \
    --project $PROJECT_ID &

gcloud compute networks subnets create management \
    --network=vpc-management \
    --range=192.168.120.0/24 \
    --region=$REGION \
    --enable-private-ip-google-access \
    --project $PROJECT_ID &

gcloud compute networks subnets create prod \
    --network=vpc-prod \
    --range=10.0.0.0/24 \
    --region=$REGION \
    --project $PROJECT_ID &

gcloud compute networks subnets create qa  \
    --project $PROJECT_ID \
    --network=vpc-qa \
    --range=10.0.1.0/24 \
    --region=$REGION & wait

gcloud compute firewall-rules create ingress-qa \
    --action allow \
    --direction=INGRESS \
    --source-ranges=0.0.0.0/0 \
    --network=vpc-qa \
    --rules all \
    --project $PROJECT_ID &
    
gcloud compute firewall-rules create ingress-prod \
    --action allow \
    --direction=INGRESS \
    --source-ranges=0.0.0.0/0 \
    --network=vpc-prod \
    --rules all \
    --project $PROJECT_ID &

gcloud compute firewall-rules create rdp-management \
    --action allow \
    --direction=INGRESS \
    --source-ranges=0.0.0.0/0 \
    --network=vpc-management \
    --rules tcp:3389 \
    --project $PROJECT_ID & wait


gcloud compute instances create rdp-client \
    --project $PROJECT_ID \
    --zone=$ZONE \
    --machine-type=n1-standard-4 \
    --image-project=qwiklabs-resources \
    --image=sap-rdp-image \
    --network=vpc-management \
    --subnet=management \
    --tags=rdp,http-server,https-server \
    --boot-disk-type=pd-ssd &

gcloud compute instances create linux-qa \
    --project $PROJECT_ID \
    --zone $ZONE \
    --image-project=debian-cloud \
    --image-family=debian-11 \
    --custom-cpu 1 \
    --custom-memory 4 \
    --network-interface subnet=qa,private-network-ip=10.0.1.4,no-address \
    --metadata startup-script="\#! /bin/bash
useradd -m -p sa1trmaMoZ25A cp
EOF" &

gcloud compute instances create linux-prod \
    --project $PROJECT_ID \
    --zone $ZONE \
    --image-project=debian-cloud \
    --image-family=debian-11 \
    --custom-cpu 1 \
    --custom-memory 4 \
    --network-interface subnet=prod,private-network-ip=10.0.0.4,no-address \
    --metadata startup-script="\#! /bin/bash
useradd -m -p sa1trmaMoZ25A cp
EOF" & wait

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#