export COLLAGE_SCHED_SA=collage-schedule-sa

gcloud iam service-accounts create ${COLLAGE_SCHED_SA}

gcloud run services add-iam-policy-binding ${COLLAGE_SERVICE_NAME} \
    --region=${REGION} \
    --member="serviceAccount:${COLLAGE_SCHED_SA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

college_url=$(gcloud run services describe ${COLLAGE_SERVICE_NAME} \
                --platform managed \
                --region ${REGION} \
                --format 'value(status.url)')

gcloud scheduler jobs create http collage-schedule \
    --schedule "* * * * *" \
    --uri $college_url \
    --http-method POST \
    --location $REGION \
    --oidc-service-account-email $COLLAGE_SCHED_SA@$PROJECT_ID.iam.gserviceaccount.com