
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp294

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    # FIntes & Universal Terms Required!
    if gcloud services enable fitness.googleapis.com --project $PROJECT_ID; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

export OAUTH2_TOKEN=$(gcloud auth print-access-token --project $PROJECT_ID)

echo '{
  "name": "'"$PROJECT_ID"'-bucket",
  "location": "us",
  "storageClass": "multi_regional"
}' > values.json

curl -X POST --data-binary @values.json \
    -H "Authorization: Bearer $OAUTH2_TOKEN" \
    -H "Content-Type: application/json" \
    "https://www.googleapis.com/storage/v1/b?project=$PROJECT_ID"

curl -X POST --data-binary @demo-image.png \
    -H "Authorization: Bearer $OAUTH2_TOKEN" \
    -H "Content-Type: image/png" \
    "https://www.googleapis.com/upload/storage/v1/b/$PROJECT_ID-bucket/o?uploadType=media&name=demo-image"


#  ----------------------- ALTERNATIVE ------------------------------

# gsutil mb -p $PROJECT_ID gs://$PROJECT_ID-bucket

# gsutil cp demo-image.jpg gs://$PROJECT_ID-bucket/demo-image.jpg


echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#