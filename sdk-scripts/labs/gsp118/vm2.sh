gcloud compute networks subnets create private-ad-zone-2 \
    --network $VPC_NAME \
    --range 10.2.0.0/24 \
    --region $REGION_2 \
    --project $PROJECT_ID

gcloud compute instances create ad-dc2 \
    --machine-type e2-standard-2 \
    --boot-disk-size 50GB \
    --boot-disk-type pd-ssd \
    --image-family windows-2016 \
    --image-project windows-cloud \
    --can-ip-forward \
    --zone $ZONE_2 \
    --network $VPC_NAME \
    --subnet private-ad-zone-2 \
    --private-network-ip=10.2.0.100 \
    --project $PROJECT_ID 