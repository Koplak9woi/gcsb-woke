
cd ./sample-py-app

deploy_function(){
    # yes | gcloud run deploy sample-py-app \
    #     --source . \
    #     --region=$REGION \
    #     --allow-unauthenticated \
    #     --project $PROJECT_ID

    yes | gcloud run deploy sample-py-app \
        --region=$REGION \
        --project=$PROJECT_ID \
        --port=8080 \
        --image="us-docker.pkg.dev/cloudrun/container/hello" \
        --allow-unauthenticated \
        --platform=managed \
        --execution-environment=gen2
}

deployed=false
while [ "$deployed" = false ]; do
    if deploy_function; then
        echo "Deploy Success"
        deployed=true
    else
        echo "Re-trying to Deploy..."
    fi
done