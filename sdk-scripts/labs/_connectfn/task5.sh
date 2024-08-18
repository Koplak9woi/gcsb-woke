
# ====================================== TASK 5 =========================================
cd ./redis-http

deploy_function() {
    gcloud functions deploy http-get-redis \
        --gen2 \
        --runtime python310 \
        --entry-point getFromRedis \
        --source . \
        --region $REGION \
        --trigger-http \
        --timeout 600s \
        --max-instances 1 \
        --vpc-connector projects/$PROJECT_ID/locations/$REGION/connectors/test-connector \
        --set-env-vars REDISHOST=$REDIS_IP,REDISPORT=$REDIS_PORT \
        --no-allow-unauthenticated
}

deploy_success=false
while [ "$deploy_success" = false ]; do
    if deploy_function; then
        echo "Function deployed successfully..."
        deploy_success=true
    else
        echo "Retrying..."
    fi
done

FUNCTION_URI=$(gcloud functions describe http-get-redis --gen2 --region $REGION --format "value(serviceConfig.uri)"); echo $FUNCTION_URI

curl -H "Authorization: bearer $(gcloud auth print-identity-token)" "${FUNCTION_URI}?id=1234"