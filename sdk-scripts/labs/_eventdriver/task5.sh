cd ./code/cloud-functions/${EXTRACT_FUNCTION_NAME}

deploy_function(){
	gcloud functions deploy ${EXTRACT_FUNCTION_NAME} \
		--source . \
		--runtime=nodejs18 \
		--entry-point=extract_image_metadata \
		--trigger-http \
		--no-allow-unauthenticated \
        --region $REGION
}
deploy_success=false

while [ "$deploy_success" = false ]; do
    if deploy_function; then
        echo "$EXTRACT_FUNCTION_NAME succesfully deployed"
        deploy_success=true
    else
        echo "Deploying $EXTRACT_FUNCTION_NAME..."
    fi
done