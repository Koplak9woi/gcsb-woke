
# ===================================== TASK 3 ====================================

gcloud compute networks vpc-access connectors create test-connector \
    --region=$REGION \
    --machine-type=e2-micro \
    --network=default \
    --range=10.8.0.0/28 \
    --max-instances=10 \
    --min-instances=2