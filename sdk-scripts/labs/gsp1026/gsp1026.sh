
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp1026

./bucket.sh &

gcloud beta container clusters create gmp-cluster \
    --num-nodes=1 \
    --zone $ZONE \
    --enable-managed-prometheus \
    --project=$PROJECT_ID

gcloud container clusters get-credentials gmp-cluster --zone=$ZONE --project $PROJECT_ID

kubectl create ns gmp-test

kubectl -n gmp-test apply -f ./example-app.yaml

kubectl -n gmp-test apply -f ./pod-monitoring.yaml


echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#