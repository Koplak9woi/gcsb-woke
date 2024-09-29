#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

create_notebook(){
    yes | gcloud notebooks instances create my-notebook \
        --project=$PROJECT_ID \
        --location $ZONE \
        --vm-image-project=deeplearning-platform-release \
        --vm-image-family=tf-2-11-cu113-notebooks \
        --machine-type e2-standard-2
}
success=false
while [ "$success" = false ]; do
    if create_notebook; then
        echo "Vertex AI Notebook Created"
        success=true
    else
        echo "Retrying Enable API"
    fi
done

sleep 20

ssh_connect(){
    gcloud compute ssh $USER_NAME@my-notebook \
        --zone=$ZONE \
        --project=$PROJECT_ID \
        --command=<<'EOF_END'
USER=$(whoami)
sudo chown -R "$USER:" /home/jupyter
cd /home/jupyter
DIR=training-data-analyst/blogs
mkdir -p $DIR && cd $DIR
git clone https://gist.github.com/AguzzTN54/d4d77ba780d2db77435770c563cac1c2 ./bitcoin_network && cd bitcoin_network
jupyter nbconvert --execute visualizing_the_10000_pizza_bitcoin_network.ipynb --to notebook
EOF_END
}

success=false
while [ "$success" = false ]; do
    if ssh_connect; then
        echo "SSH Connection Success, Executing Commands Success"
        success=true
    else
        echo "Waiting for Connections"
    fi
done


echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
