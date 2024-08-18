
# ================================ TASK 4 ===========================================

cd ./redis-pubsub

deploy_function() {
    gcloud functions deploy python-pubsub-function \
        --runtime=python310 \
        --region=$REGION \
        --source=. \
        --entry-point=addToRedis \
        --trigger-topic=$TOPIC \
        --vpc-connector projects/$PROJECT_ID/locations/$REGION/connectors/test-connector \
        --set-env-vars REDISHOST=$REDIS_IP,REDISPORT=$REDIS_PORT
}

deploy_success=false
while [ "$deploy_success" = false ]; do
    if deploy_function; then
        echo "Function deployed successfully..."
        deploy_success=true
    else
        echo "Retrying in 20 seconds..."
    fi
done

gcloud pubsub topics publish $TOPIC \
    --message='{"id": 1234, "firstName": "Lucas" ,"lastName": "Sherman", "Phone": "555-555-5555"}'