
cd ./code/1-HelloWorld

gcloud app create --region=$REGION --project $PROJECT_ID

deploy_success=false
while [ "$deploy_success" = false ]; do
  if yes | gcloud app deploy --project $PROJECT_ID; then
    echo "Function deployed successfully."
    deploy_success=true
  else
    echo "Retrying..."
  fi
done