
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

# export REGION=$(gcloud container clusters list --format='value(LOCATION)')

echo "${CYAN}${BOLD}Click here: "${RESET}""${BLUE}${BOLD}"https://console.cloud.google.com/logs/storage/bucket?project=$PROJECT_ID""${RESET}"

cd ./labs/gsp1088

gcloud container clusters get-credentials day2-ops \
    --region $REGION \
    --project $PROJECT_ID

kubectl apply -f release/kubernetes-manifests.yaml &

gcloud logging buckets update _Default \
    --location=global \
    --project $PROJECT_ID \
    --enable-analytics &

gcloud logging sinks create day2ops-sink \
    logging.googleapis.com/projects/$PROJECT_ID/locations/global/buckets/day2ops-log \
    --log-filter='resource.type="k8s_container"' \
    --include-children \
    --project $PROJECT_ID \
    --format='json' & wait

EXTERNAL_IP=$(kubectl get service frontend-external -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo $EXTERNAL_IP
curl -o /dev/null -s -w "%{http_code}\n"  http://${EXTERNAL_IP}


#   gcloud logging buckets create day2ops-log --location global --enable-analytics
#   gcloud alpha logging links create day2ops_log --bucket=day2ops-log --location=global
# TOKEN=$(gcloud auth print-access-token)
#   curl -X POST -H "Content-Type: application/json" \
#   -H "Authorization: Bearer $TOKEN" \
#   "https://logging.googleapis.com/v2/projects/$PROJECT_ID/locations/global/buckets/day2ops-log/links?linkId=day2ops_log"

#-----------------------------------------------------end----------------------------------------------------------#