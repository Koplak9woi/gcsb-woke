gcloud compute instances create test-client \
    --project $PROJECT_ID \
    --zone=$ZONE \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --machine-type=e2-micro

install_mysql_in_vm(){
    gcloud compute ssh $USER_NAME@test-client \
        --project $PROJECT_ID \
        --zone $ZONE \
        --command "sudo apt-get install -y default-mysql-client"
}

success=false
while [ "$success" = false ]; do
    if install_mysql_in_vm; then
        echo "Installing mysql Success"
        success=true
    else
        echo "Waiting for Connections"
    fi
done