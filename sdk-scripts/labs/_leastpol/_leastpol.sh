# Implementing Least Privilege IAM Policy Bindings in Cloud Run [APPRUN]

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

# ================================ TASK 1 ========================================
lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if gcloud services enable run.googleapis.com --project $PROJECT_ID; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

# gcloud config set run/region $REGION

cd ./labs/_leastpol

# ===================================== TASK 2 =============================================

 gcloud run deploy billing-service \
    --image gcr.io/qwiklabs-resources/gsp723-parking-service \
    --region $REGION \
    --allow-unauthenticated \
    --project $PROJECT_ID &

gcloud run deploy billing-service-2 \
    --image gcr.io/qwiklabs-resources/gsp723-parking-service \
    --region $REGION \
    --no-allow-unauthenticated \
    --project $PROJECT_ID & wait

# curl -X POST -H "Content-Type: application/json" $BILLING_SERVICE_URL -d '{"userid": "1234", "minBalance": 100}'


#  =============================== TASK 3 ================================
gcloud run deploy billing-service \
    --image gcr.io/qwiklabs-resources/gsp723-parking-service \
    --region $REGION \
    --no-allow-unauthenticated \
    --project $PROJECT_ID

BILLING_SERVICE_2_URL=$(gcloud run services list \
    --format='value(URL)' \
    --project $PROJECT_ID \
    --filter="billing-service-2") &

BILLING_SERVICE_URL=$(gcloud run services list \
    --project $PROJECT_ID \
    --format='value(URL)' \
    --filter="billing-service") 


curl -X POST -H "Content-Type: application/json" $BILLING_SERVICE_URL -d '{"userid": "1234", "minBalance": 100}' &

gcloud iam service-accounts create billing-initiator \
    --display-name="Billing Initiator" \
    --project $PROJECT_ID

export BILLING_INITIATOR_EMAIL="billing-initiator@$PROJECT_ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$BILLING_INITIATOR_EMAIL" \
    --role="roles/run.invoker" \
    --project $PROJECT_ID &

# =================================== TASK 4 ==============================

#  BILLING_INITIATOR_EMAIL=$(gcloud iam service-accounts list \
#     --filter="Billing Initiator" \
#     --format="value(EMAIL)" \
#     --project $PROJECT_ID)
# echo $BILLING_INITIATOR_EMAIL

gcloud iam service-accounts keys create key.json \
    --project $PROJECT_ID \
    --iam-account=${BILLING_INITIATOR_EMAIL} &

gcloud run services add-iam-policy-binding billing-service \
    --region $REGION \
    --project $PROJECT_ID \
    --member=serviceAccount:${BILLING_INITIATOR_EMAIL} \
    --role=roles/run.invoker \
    --platform managed & wait

# ==============================================================================
gcloud auth activate-service-account --key-file=key.json --project=$PROJECT_ID
TOKEN=$(gcloud auth print-identity-token --project $PROJECT_ID)
# ==============================================================================

# Shell 2
curl -X POST -H "Content-Type: application/json" $BILLING_SERVICE_URL \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"userid": "1234", "minBalance": 500}' &

curl -X POST -H "Content-Type: application/json" $BILLING_SERVICE_URL \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"userid": "1234", "minBalance": 700}' &

curl -X POST -H "Content-Type: application/json" $BILLING_SERVICE_2_URL \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"userid": "1234", "minBalance": 900}' &

curl -X POST -H "Content-Type: application/json" $BILLING_SERVICE_2_URL \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"userid": "1234", "minBalance": 500}' & wait

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#