#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp075

gcloud alpha services api-keys create --display-name="awesome" --project $PROJECT_ID

KEY_NAME=$(gcloud alpha services api-keys list \
    --project $PROJECT_ID \
    --format="value(name)" \
    --filter "displayName=awesome")

API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME \
    --project $PROJECT_ID \
    --format="value(keyString)")

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)" \
    --project $PROJECT_ID)

gcloud storage buckets create gs://$PROJECT_ID-bucket --project=$PROJECT_ID

# gsutil iam ch projectEditor:serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com:objectCreator gs://$PROJECT_ID-bucket


gsutil cp sign.jpg gs://$PROJECT_ID-bucket/sign.jpg

gsutil acl ch -u AllUsers:R gs://$PROJECT_ID-bucket/sign.jpg


# cat > ocr-request.json <<EOF
# {
#   "requests": [
#       {
#         "image": {
#           "source": {
#               "gcsImageUri": "gs://$PROJECT_ID-bucket/sign.jpg"
#           }
#         },
#         "features": [
#           {
#             "type": "TEXT_DETECTION",
#             "maxResults": 10
#           }
#         ]
#       }
#   ]
# }
# EOF

# curl -s -X POST -H "Content-Type: application/json" \
#     --data-binary @ocr-request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

# curl -s -X POST -H "Content-Type: application/json" \
#     -o ocr-response.json \
#     --data-binary @ocr-request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} 


# cat > translation-request.json <<EOF
# {
#   "q": "My Name is MD_SOHRAB",	
#   "target": "en"
# }
# EOF

# STR=$(jq .responses[0].textAnnotations[0].description ocr-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" translation-request.json

# curl -s -X POST -H "Content-Type: application/json" \
#     -o translation-response.json \
#     --data-binary @translation-request.json https://translation.googleapis.com/language/translate/v2?key=${API_KEY} 


# cat > nl-request.json <<EOF
# {
#   "document":{
#     "type":"PLAIN_TEXT",
#     "content":"your_text_here"
#   },
#   "encodingType":"UTF8"
# }
# EOF

# STR=$(jq .data.translations[0].translatedText  translation-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" nl-request.json

curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @nl-request.json

  echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#