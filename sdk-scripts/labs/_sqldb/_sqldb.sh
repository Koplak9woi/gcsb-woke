
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

success=false
while [ "$success" = false ]; do
    if gcloud services enable sqladmin.googleapis.com --project $PROJECT_ID; then
        echo "SQL API Enabled"
        success=true
    else
        echo "Retrying Enable API"
    fi
done

cd ./labs/_sqldb

create_postgres(){
    gcloud sql instances create postgresql-db \
        --zone=$ZONE \
        --project $PROJECT_ID \
        --database-version=POSTGRES_14 \
        --tier=db-custom-1-3840 \
        --root-password=awesome \
        --edition=ENTERPRISE

    gcloud sql databases create petsdb \
        --project $PROJECT_ID \
        --instance=postgresql-db
}

INSTANCE_NAME="mysql-db"
create_mysql(){
    gcloud sql instances create $INSTANCE_NAME \
        --project $PROJECT_ID \
        --zone=$ZONE \
        --tier=db-n1-standard-1
}

./test_vm.sh & create_postgres & create_mysql

EXTERNAL=$(gcloud compute instances list --format='value(EXTERNAL_IP)' --project $PROJECT_ID)
yes | gcloud sql instances patch $INSTANCE_NAME \
        --project $PROJECT_ID \
        --authorized-networks=$EXTERNAL

PUBLIC_IP=$(gcloud sql instances describe $INSTANCE_NAME --format="value(ipAddresses.ipAddress)" --project $PROJECT_ID)

ssh_connect(){
    gcloud compute ssh $USER_NAME@test-client \
        --project $PROJECT_ID \
        --zone $ZONE \
        --command "mysql --host=$PUBLIC_IP --user=root --password"
}

success=false
while [ "$success" = false ]; do
    if ssh_connect; then
        echo "SSH Connection Success"
        success=true
    else
        echo "Waiting for Connections"
    fi
done

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#