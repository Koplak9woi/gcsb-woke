gcloud compute networks subnets create private-ad-zone-1 \
    --network $VPC_NAME \
    --range 10.1.0.0/24 \
    --region $REGION_1 \
    --project $PROJECT_ID
  
gcloud compute instances create ad-dc1 \
    --machine-type e2-standard-2 \
    --boot-disk-type pd-ssd \
    --boot-disk-size 50GB \
    --image-family windows-2016 \
    --image-project windows-cloud \
    --network $VPC_NAME \
    --zone $ZONE_1 \
    --subnet private-ad-zone-1 \
    --private-network-ip=10.1.0.100  \
    --project $PROJECT_ID