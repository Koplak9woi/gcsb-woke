echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"


# gcloud auth list

# gcloud config set compute/region $REGION

# git clone https://github.com/GoogleCloudPlatform/terraform-google-lb
# cd ~/terraform-google-lb/examples/basic

cd ./labs/gsp191/basic

export GOOGLE_PROJECT=$PROJECT_ID

cat > terraform.tfstate <<'EOF_END'
{
  "version": 4,
  "terraform_version": "1.9.4",
  "serial": 22,
  "lineage": "2ab84e13-0451-bc24-3565-b823efc38175",
  "outputs": {},
  "resources": [],
  "check_results": null
}
EOF_END

cat > variables.tf <<EOF_END
variable "region" {
  default = "$REGION"
}

variable "project_id" {
  description = "GCP Project used to create resources."
  default     = "$PROJECT_ID"
}

variable "image_family" {
  description = "Image used for compute VMs."
  default     = "debian-11"
}

variable "image_project" {
  description = "GCP Project where source image comes from."
  default     = "debian-cloud"
}
EOF_END

# sed -i 's/us-central1/'"$REGION"'/g' variables.tf

# terraform init

# terraform plan

terraform apply --auto-approve

EXTERNAL_IP=$(terraform output | grep load_balancer_default_ip | cut -d = -f2 | xargs echo -n)

# echo "http://${EXTERNAL_IP}"

curl $EXTERNAL_IP
curl $EXTERNAL_IP
curl $EXTERNAL_IP
curl $EXTERNAL_IP
curl $EXTERNAL_IP
curl $EXTERNAL_IP



echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"
