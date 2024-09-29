
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"


bank_instance1(){
    gcloud spanner instances create banking-instance \
        --project $PROJECT_ID \
        --config=regional-$REGION  \
        --description="awesome" \
        --nodes=1

    gcloud spanner databases create banking-db \
        --project $PROJECT_ID \
        --instance=banking-instance \
        --ddl="CREATE TABLE Customer (
  CustomerId STRING(36) NOT NULL,
  Name STRING(MAX) NOT NULL,
  Location STRING(MAX) NOT NULL,
) PRIMARY KEY (CustomerId);"
}

bank_instance2(){
    gcloud spanner instances create banking-instance-2 \
        --project $PROJECT_ID \
        --config=regional-$REGION  \
        --description="awesome" \
        --nodes=2

    gcloud spanner databases create banking-db-2 \
        --project $PROJECT_ID \
        --instance=banking-instance-2
}

bank_instance2 & bank_instance1 & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#