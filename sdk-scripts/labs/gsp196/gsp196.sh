#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"


# git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/

cd ./labs/gsp196

export BUCKET=${PROJECT_ID}-ml

# gsutil cp create_table.sql gs://$BUCKET/create_table.sql &

cd ./03_sqlstudio

gcloud sql instances create flights \
    --database-version=POSTGRES_13 \
    --cpu=2 \
    --memory=8GiB \
    --root-password=Passw0rd \
    --region=$REGION \
    --project $PROJECT_ID 

export ADDRESS=$(curl -s http://ipecho.net/plain)/32

yes | gcloud sql instances patch flights --authorized-networks $ADDRESS --project $PROJECT_ID

export INSTANCE_NAME=flights
export DATABASE_NAME=bts
export SQL_FILE=create_table.sql

# Create a database
gcloud sql databases create $DATABASE_NAME --instance=$INSTANCE_NAME --project $PROJECT_ID

# SERVICE_ACCOUNT_EMAIL=$(gcloud sql instances describe $INSTANCE_NAME --project $PROJECT_ID --format='value(serviceAccountEmailAddress)')

gsutil iam ch serviceAccount:$USER_EMAIL:roles/storage.objectViewer gs://$BUCKET

# Import the SQL file into the database
gcloud sql import sql $INSTANCE_NAME \
    gs://$BUCKET/$SQL_FILE \
    --database=$DATABASE_NAME \
    --project $PROJECT_ID

    
echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#