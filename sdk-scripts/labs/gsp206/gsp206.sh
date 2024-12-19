
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp206/terra

cat > terraform.tfstate <<'EOF_END'
{
  "version": 4,
  "terraform_version": "1.9.4",
  "serial": 8,
  "lineage": "a0594bcb-4c5b-42a9-27d6-a05507aac477",
  "outputs": {},
  "resources": [],
  "check_results": null
}
EOF_END

# terraform init 

terraform apply --auto-approve \
  -var="project=$PROJECT_ID" \
  -var="group1_region=$REGION_1" \
  -var="group2_region=$REGION_2" \
  -var="group3_region=$REGION_3"

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------