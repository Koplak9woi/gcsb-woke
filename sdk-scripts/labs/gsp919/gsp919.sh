
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

export REGION="${ZONE%-*}"
export REPO=gmemegen
export SERVICE_ACCOUNT=cloudsql-service-account

# gcloud config set compute/zone $ZONE
# gcloud config set compute/region $REGION

# gcloud services enable artifactregistry.googleapis.com
# sleep 10

cd ./labs/gsp919

gcloud iam service-accounts create $SERVICE_ACCOUNT --project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin" \
    --project $PROJECT_ID

gcloud iam service-accounts keys create key.json \
    --iam-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --project=$PROJECT_ID

gcloud container clusters create postgres-cluster \
    --zone=$ZONE \
    --num-nodes=2 \
    --project=$PROJECT_ID    

kubectl create secret generic cloudsql-instance-credentials \
    --from-file=credentials.json=key.json 
    
kubectl create secret generic cloudsql-db-credentials \
    --from-literal=username=postgres \
    --from-literal=password=supersecret! \
    --from-literal=dbname=gmemegen_db

gsutil -m cp -r gs://spls/gsp919/gmemegen .
cd gmemegen

gcloud auth configure-docker ${REGION}-docker.pkg.dev --project=$PROJECT_ID

gcloud artifacts repositories create $REPO \
    --repository-format=docker --location=$REGION \
    --project=$PROJECT_ID

docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/gmemegen/gmemegen-app:v1 .

docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/gmemegen/gmemegen-app:v1

sed -i "33c\          image: $REGION-docker.pkg.dev/$PROJECT_ID/gmemegen/gmemegen-app:v1" gmemegen_deployment.yaml

sed -i "60c\                    "-instances=$PROJECT_ID:$REGION:postgres-gmemegen=tcp:5432"," gmemegen_deployment.yaml

kubectl create -f gmemegen_deployment.yaml

kubectl get pods

sleep 25

kubectl expose deployment gmemegen \
    --type "LoadBalancer" \
    --port 80 --target-port 8080

kubectl describe service gmemegen

export LOAD_BALANCER_IP=$(kubectl get svc gmemegen \
-o=jsonpath='{.status.loadBalancer.ingress[0].ip}' -n default)
echo gMemegen Load Balancer Ingress IP: http://$LOAD_BALANCER_IP

POD_NAME=$(kubectl get pods --output=json | jq -r ".items[0].metadata.name")
kubectl logs $POD_NAME gmemegen | grep "INFO"

INSTANCE_NAME="postgres-gmemegen"
DB_USER="postgres"
DB_NAME="gmemegen_db"

gcloud sql connect $INSTANCE_NAME --user=$DB_USER --quiet << EOF

\c $DB_NAME

SELECT * FROM meme;
EOF

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#