
cd ./code/2-HelloUser

deploy_success=false
while [ "$deploy_success" = false ]; do
  if yes | gcloud app deploy --project $PROJECT_ID; then
    echo "Function deployed successfully."
    deploy_success=true
  else
    echo "Retrying..."
  fi
done

cd ../3-HelloVerifiedUser

deploy_success=false
while [ "$deploy_success" = false ]; do
  if yes | gcloud app deploy --project $PROJECT_ID; then
    echo "Function deployed successfully."
    deploy_success=true
  else
    echo "Retrying..."
  fi
done