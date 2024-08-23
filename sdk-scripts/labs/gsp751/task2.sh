
cd ./terra

cat > main.tf <<EOF_END
module "gcs-static-website-bucket" {
  source = "./modules/gcs-static-website-bucket"
  name       = var.name
  project_id = var.project_id
  location   = "$REGION"
  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age        = 365
      with_state = "ANY"
    }
  }]
}
EOF_END

cat > variables.tf <<EOF_END
variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
  default     = "$PROJECT_ID"
}
variable "name" {
  description = "Name of the buckets to create."
  type        = string
  default     = "$PROJECT_ID"
}
EOF_END

terraform init

terraform apply --auto-approve

gsutil cp *.html gs://$PROJECT_ID

sleep 20

terraform destroy --auto-approve