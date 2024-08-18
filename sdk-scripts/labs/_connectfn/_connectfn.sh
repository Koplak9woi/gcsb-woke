# Connecting Cloud Functions

#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

export REGION="${ZONE%-*}"
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
cd ./labs/_connectfn

# =============================== TASK1 =============================== 
enable_lib(){
    gcloud services enable \
        artifactregistry.googleapis.com \
        cloudfunctions.googleapis.com \
        cloudbuild.googleapis.com \
        eventarc.googleapis.com \
        run.googleapis.com \
        logging.googleapis.com \
        pubsub.googleapis.com \
        redis.googleapis.com \
        vpcaccess.googleapis.com
}

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if enable_lib; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

# ===================================== TASK 2 =======================================

export REDIS_INSTANCE=customerdb
export TOPIC=add_redis

gcloud pubsub topics create $TOPIC &

gcloud redis instances create $REDIS_INSTANCE \
    --size=2 \
    --region=$REGION \
    --redis-version=redis_6_x & ./task3.sh & wait
 
gcloud redis instances describe $REDIS_INSTANCE --region=$REGION

export REDIS_IP=$(gcloud redis instances describe $REDIS_INSTANCE --region=$REGION --format="value(host)"); echo $REDIS_IP

export REDIS_PORT=$(gcloud redis instances describe $REDIS_INSTANCE --region=$REGION --format="value(port)"); echo $REDIS_PORT

# gcloud compute networks vpc-access connectors describe test-connector --region $REGION

./task4.sh & ./task5.sh & ./task6.sh & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#