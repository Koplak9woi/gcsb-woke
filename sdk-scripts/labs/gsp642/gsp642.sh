
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

gcloud firestore databases create --location=nam5 --project $PROJECT_ID

cd ./labs/gsp642/lab01

cp $GOOGLE_APPLICATION_CREDENTIALS ./adc.json

cat > .env <<EOF_CP
GOOGLE_CLOUD_PROJECT=$PROJECT_ID
GOOGLE_APPLICATION_CREDENTIALS=adc.json
EOF_CP

create_csv(){
    run_success=false
    while [ "$run_success" = false ]; do
        if "$node" createTestData 10; then
            run_success=true
        else
            echo "${RED}${BOLD}Failed to Create Test Data, Retrying ....${RESET}"
        fi
    done
}

import_csv(){
    run_success=false
    while [ "$run_success" = false ]; do
        if "$node" importTestData customers_10_import.csv; then
            echo "${GREEN}${BOLD}Importing Database Success${RESET}"
            run_success=true
        else
            echo "${RED}${BOLD}Failed to populate Firestore Database, Retrying ....${RESET}"
        fi
    done
}


create_csv & import_csv

echo "${BG_GREEN}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#