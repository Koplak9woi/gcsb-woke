#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp055/test

gcloud artifacts repositories create my-repository \
    --location=$REGION \
    --repository-format=Docker \
    --description="Awesome Lab" \
    --project $PROJECT_ID &

docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/my-repository/node-app:0.2 . & wait

gcloud auth configure-docker $REGION-docker.pkg.dev

pushed=false
while [ "$pushed" = false ]; do
    if yes | docker push $REGION-docker.pkg.dev/$PROJECT_ID/my-repository/node-app:0.2; then
        echo "Pushing Docker Success"
        pushed=true
    else
        echo "Re-trying to push docker..."
    fi
done


echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#