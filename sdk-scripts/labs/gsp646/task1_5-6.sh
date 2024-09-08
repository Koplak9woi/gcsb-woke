lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if gcloud services enable cloudscheduler.googleapis.com --project $PROJECT_ID; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

cd ./gcf-automated-resource-cleanup/unused-ip

gcloud services disable cloudfunctions.googleapis.com --project=$PROJECT_ID

gcloud services enable cloudfunctions.googleapis.com --project=$PROJECT_ID &

gcloud app create --region $REGION --project=$PROJECT_ID &

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com" \
    --role="roles/artifactregistry.reader" \
    --project=$PROJECT_ID & 

deploy_function(){
    gcloud functions deploy unused_ip_function \
        --trigger-http \
        --runtime=nodejs12 \
        --region=$REGION \
        --allow-unauthenticated \
        --project=$PROJECT_ID 
}
deployed=false
while [ "$deployed" = false ]; do
    if deploy_function; then
        echo "Cloud Function Deployed"
        deployed=true
    else
        echo "Re-trying to Deploy..."
    fi
done

export FUNCTION_URL=$(gcloud functions describe unused_ip_function \
     --project=$PROJECT_ID \
     --region=$REGION \
     --format=json | jq -r '.httpsTrigger.url')

gcloud scheduler jobs create http unused-ip-job \
    --schedule="* 2 * * *" \
    --uri=$FUNCTION_URL \
    --location=$REGION \
    --project=$PROJECT_ID


gcloud scheduler jobs run unused-ip-job --location=$REGION --project=$PROJECT_ID

gcloud compute addresses list --filter="region:($REGION)" --project=$PROJECT_ID