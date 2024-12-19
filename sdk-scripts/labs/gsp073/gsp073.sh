#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp073


gsutil mb -l $REGION -p $PROJECT_ID gs://$PROJECT_ID

# curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg

# mv ada.jpg kitten.png

gsutil cp kitten.png gs://$PROJECT_ID

gsutil cp -r gs://$PROJECT_ID/kitten.png .

gsutil cp gs://$PROJECT_ID/kitten.png gs://$PROJECT_ID/image-folder/

gsutil iam ch allUsers:objectViewer gs://$PROJECT_ID

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#