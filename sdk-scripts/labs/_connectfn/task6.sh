#  ================================= TASK 6 ==============================

# gsutil cp gs://cloud-training/CBL492/startup.sh .

# cat startup.sh

gcloud compute instances create webserver-vm \
    --image-project=debian-cloud \
    --image-family=debian-11 \
    --metadata-from-file=startup-script=./startup.sh \
    --machine-type e2-standard-2 \
    --tags=http-server \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --zone $ZONE &

gcloud compute firewall-rules create default-allow-http \
    --project=$PROJECT_ID \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server & wait

VM_INT_IP=$(gcloud compute instances describe webserver-vm --format='get(networkInterfaces[0].networkIP)' --zone $ZONE); echo $VM_INT_IP

VM_EXT_IP=$(gcloud compute instances describe webserver-vm --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone $ZONE); echo $VM_EXT_IP

cd ./vm-http

gcloud services disable cloudfunctions.googleapis.com

gcloud services enable cloudfunctions.googleapis.com

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export PROJECT_ID=$(gcloud config get-value project)

deploy_function() {
    gcloud functions deploy vm-connector \
        --runtime python310 \
        --entry-point connectVM \
        --source . \
        --region $REGION \
        --trigger-http \
        --timeout 10s \
        --max-instances 1 \
        --no-allow-unauthenticated \
        --vpc-connector projects/$PROJECT_ID/locations/$REGION/connectors/test-connector \
        --service-account "$PROJECT_NUMBER-compute@developer.gserviceaccount.com"
}

deploy_success=false
while [ "$deploy_success" = false ]; do
    deploy_function
    if gcloud functions describe vm-connector --region=$REGION &> /dev/null; then
        echo "Function deployed successfully..."
        deploy_success=true
    else
        echo "Retrying in 30 seconds..."
    fi
done

curl -H "Authorization: bearer $(gcloud auth print-identity-token)" "${FUNCTION_URI}?ip=$VM_INT_IP"

gcloud pubsub topics publish $TOPIC \
    --message='{"id": 1234, "firstName": "Lucas" ,"lastName": "Sherman", "Phone": "555-555-5555"}'
