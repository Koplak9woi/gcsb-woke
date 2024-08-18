# Developing and Deploying Cloud Functions

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

# ======================== TASK 1 ================================

enable_lib(){
    gcloud services enable \
        artifactregistry.googleapis.com \
        cloudfunctions.googleapis.com \
        cloudbuild.googleapis.com \
        eventarc.googleapis.com \
        run.googleapis.com \
        logging.googleapis.com \
        storage.googleapis.com \
        pubsub.googleapis.com
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

cd ./labs/_deployfn
./task2-5.sh & ./task3.sh & wait


echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"