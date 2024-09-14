
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

create_topic(){
    gcloud beta pubsub topics create new-doc --project $PROJECT_ID

    gcloud beta pubsub subscriptions create pdf-conv-sub \
        --topic new-doc \
        --project $PROJECT_ID
}

cd ./labs/gsp644

./build.sh &
./deploy.sh &
create_topic &

gsutil mb -p $PROJECT_ID gs://$PROJECT_ID-processed &

gsutil mb -p $PROJECT_ID gs://$PROJECT_ID-upload

gsutil notification create -p $PROJECT_ID -t new-doc -f json -e OBJECT_FINALIZE gs://$PROJECT_ID-upload & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#