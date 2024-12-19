#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp1166

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if gcloud services enable aiplatform.googleapis.com --project $PROJECT_ID; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

cd palm2

"/mnt/c/Program Files/nodejs/node.exe" index.js --project $PROJECT_ID &

# echo "https://console.cloud.google.com/vertex-ai/colab/import/https:%2F%2Fraw.githubusercontent.com%2FGoogleCloudPlatform%2Fvertex-ai-samples%2Fmain%2Fnotebooks%2Fcommunity%2Fmodel_garden%2Fmodel_garden_pytorch_owlvit.ipynb?project=$PROJECT_ID"

# echo "https://console.cloud.google.com/vertex-ai/pipelines/vertex-ai-templates/bert-finetuning;versionId=sha256:0caf76450a3db5d768462d4846b4fb164845b0fc68383f6b4d7494be6bb7cf30/details?project=$PROJECT_ID"

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#