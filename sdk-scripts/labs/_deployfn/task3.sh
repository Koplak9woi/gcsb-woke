# ===================================== TASK 3 =======================================
cd ./temp-data-checker

SERVICE_ACCOUNT=$(gcloud storage service-agent)
BUCKET="gs://gcf-temperature-data-$PROJECT_ID"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT \
    --role roles/pubsub.publisher &

gcloud storage cp gs://cloud-training/CBL491/data/average-temps.csv ./data &

gcloud storage buckets create -l $REGION $BUCKET & wait

deploy_function(){
    gcloud functions deploy temperature-data-checker \
        --gen2 \
        --runtime nodejs20 \
        --entry-point checkTempData \
        --source . \
        --region $REGION \
        --trigger-bucket $BUCKET \
        --trigger-location $REGION \
        --max-instances 1
}

deploy_success=false
while [ "$deploy_success" = false ]; do
    if deploy_function; then
        echo "Storage Function Created"
        deploy_success=true
    else
        echo "Waiting for Storage Funtion to be created..."
    fi
done

cd ../data
 gcloud storage cp ./average-temps.csv $BUCKET/average-temps.csv
