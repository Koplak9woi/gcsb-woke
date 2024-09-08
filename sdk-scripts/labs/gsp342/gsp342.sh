
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp342

cat > role-definition.yaml <<EOF_END
title: "$CUSTOM_ROLE"
description: "Permissions"
stage: "ALPHA"
includedPermissions:
- storage.buckets.get
- storage.objects.get
- storage.objects.list
- storage.objects.update
- storage.objects.create
EOF_END

gcloud iam service-accounts create orca-private-cluster-sa \
    --display-name "Orca Private Cluster Service Account" \
    --project $PROJECT_ID

gcloud iam roles create $CUSTOM_ROLE \
    --project $PROJECT_ID \
    --file role-definition.yaml

gcloud iam service-accounts create $SERVICE_ACCOUNT \
    --display-name "Orca Private Cluster Service Account" \
    --project $PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/monitoring.viewer \
    --project $PROJECT_ID &

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/monitoring.metricWriter \
    --project $PROJECT_ID 

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/logging.logWriter \
    --project $PROJECT_ID &

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --role projects/$PROJECT_ID/roles/$CUSTOM_ROLE \
    --project $PROJECT_ID &

gcloud container clusters create $CLUSTER \
    --num-nodes 1 \
    --master-ipv4-cidr=172.16.0.64/28 \
    --network orca-build-vpc \
    --subnetwork orca-build-subnet \
    --enable-master-authorized-networks  \
    --master-authorized-networks 192.168.10.2/32 \
    --enable-ip-alias \
    --enable-private-nodes \
    --enable-private-endpoint \
    --service-account $SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --zone $ZONE \
    --project $PROJECT_ID

gcloud compute ssh "orca-jumphost" \
    --zone=$ZONE \
    --project=$PROJECT_ID \
    --command=<<EOF_END
gcloud config set compute/zone $ZONE

gcloud container clusters get-credentials $CLUSTER \
    --internal-ip \
    --zone $ZONE

sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y

kubectl create deployment hello-server \
    --image=gcr.io/google-samples/hello-app:1.0
    
kubectl expose deployment hello-server \
    --name orca-hello-service \
    --type LoadBalancer \
    --port 80 \
    --target-port 8080
EOF_END


echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#