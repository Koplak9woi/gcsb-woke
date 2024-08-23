echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

REGION=${ZONE%-*}

# gsutil -m cp -r gs://spls/gsp233/* .

cd ./labs/gsp233
cd tf-gke-k8s-service-lb

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

cat > variables.tf <<EOF_END
variable "region" {
  type        = string
  description = "Region for the resource."
  default     = "$REGION"
}

variable "location" {
  type        = string
  default     = "$ZONE"
  description = "Location represents region/zone for the resource."
}

variable "network_name" {
  default = "tf-gke-k8s"
}
EOF_END

# terraform init

terraform apply --auto-approve


echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"
