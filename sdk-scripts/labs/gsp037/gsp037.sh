#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp037

# enable_service(){
#     gcloud services enable apikeys.googleapis.com --project $PROJECT_ID
# }

# lib_enabled=false
# while [ "$lib_enabled" = false ]; do
# 	if enable_service; then
# 		echo "API ENABLED, continuing.."
# 		lib_enabled=true
# 	else
# 		echo "Retrying to Enable Required APIs..."
# 	fi
# done

echo "IKI project $PROJECT_ID"

gcloud alpha services api-keys create --display-name="awesome" --project $PROJECT_ID

# KEY_NAME=$(gcloud alpha services api-keys list \
# 	--format="value(name)" \
# 	--filter "displayName=awesome" \
# 	--project $PROJECT_ID )

# export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME \
# 	--project $PROJECT_ID \
# 	--format="value(keyString)")


gsutil mb -p $PROJECT_ID gs://$PROJECT_ID

gsutil cp donuts.png gs://$PROJECT_ID &

gsutil cp selfie.png gs://$PROJECT_ID &

gsutil cp city.png gs://$PROJECT_ID & wait

gsutil acl ch -u AllUsers:R gs://$PROJECT_ID/donuts.png &

gsutil acl ch -u AllUsers:R gs://$PROJECT_ID/selfie.png &

gsutil acl ch -u AllUsers:R gs://$PROJECT_ID/city.png & wait

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#