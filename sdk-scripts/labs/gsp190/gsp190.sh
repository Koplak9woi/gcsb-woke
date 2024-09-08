
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp190

./role-editor.sh &

gcloud iam roles create viewer \
    --project $PROJECT_ID \
    --title "Role Viewer" \
    --description "Custom role description." \
    --permissions compute.instances.get,compute.instances.list,storage.buckets.get,storage.buckets.list \
    --stage DISABLED

# gcloud iam roles update viewer \
#     --project $PROJECT_ID \
#     --add-permissions storage.buckets.get,storage.buckets.list

# gcloud iam roles update viewer \
#     --project $PROJECT_ID \
#     --stage DISABLED

gcloud iam roles delete viewer --project $PROJECT_ID 

gcloud iam roles undelete viewer --project $PROJECT_ID 

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#