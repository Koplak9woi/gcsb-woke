gcloud compute networks create example-vpc \
    --subnet-mode auto \
    --bgp-routing-mode global \
    --description "The name of the VPC network being created" \
    --project $PROJECT_ID

gcloud compute networks subnets create subnet-01 \
    --network example-vpc \
    --range 10.10.10.0/24 \
    --purpose PRIVATE \
    --project $PROJECT_ID \
    --region $REGION &

gcloud compute networks subnets create subnet-02 \
    --network example-vpc \
    --range 10.10.20.0/24 \
    --purpose PRIVATE \
    --enable-flow-logs \
    --enable-private-ip-google-access \
    --logging-metadata include-all \
    --logging-filter-expr true \
    --project $PROJECT_ID \
    --region $REGION &

gcloud compute networks subnets create subnet-03 \
    --network example-vpc \
    --range 10.10.30.0/24 \
    --purpose PRIVATE \
    --enable-flow-logs \
    --logging-aggregation-interval interval-10-min \
    --logging-flow-sampling 0.7 \
    --logging-metadata include-all \
    --project $PROJECT_ID \
    --logging-filter-expr false \
    --region $REGION &

wait

yes | gcloud compute networks subnets delete  subnet-01 subnet-02 subnet-03 --region $REGION --project $PROJECT_ID

yes | gcloud compute networks delete example-vpc --project $PROJECT_ID