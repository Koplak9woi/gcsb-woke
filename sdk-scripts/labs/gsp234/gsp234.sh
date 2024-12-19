
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

# mkdir sql-with-terraform

cd ./labs/gsp234/terra

# cat > terraform.tfstate <<'EOF_END'
# {
#   "version": 4,
#   "terraform_version": "1.9.4",
#   "serial": 8,
#   "lineage": "a0594bcb-4c5b-42a9-27d6-a05507aac477",
#   "outputs": {},
#   "resources": [],
#   "check_results": null
# }
# EOF_END

# gsutil cp -r gs://spls/gsp234/gsp234.zip .

# unzip gsp234.zip

# terraform init

# terraform apply -var="project=$PROJECT_ID" -var="region=$REGION" --auto-approve

# ============================ Alternative : Without Terraform =========================
gcloud sql instances create example-mysql-0345 \
  --database-version=MYSQL_5_6 \
  --tier=db-f1-micro \
  --region=$REGION \
  --storage-auto-increase \
  --project $PROJECT_ID

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#