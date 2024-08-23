#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp752

# cat > main.tf <<EOF_END

# provider "google" {
#   project     = "$PROJECT_ID"
#   region      = "$REGION"
# }
# resource "google_storage_bucket" "test-bucket-for-state" {
#   name        = "$PROJECT_ID"
#   location    = "US"
#   uniform_bucket_level_access = true
# }

# terraform {
#   backend "local" {
#     path = "terraform/state/terraform.tfstate"
#   }
# }
# EOF_END

# terraform init

# terraform apply --auto-approve

# cat > main.tf <<EOF_END

# provider "google" {
#   project     = "$PROJECT_ID"
#   region      = "$REGION"
# }
# resource "google_storage_bucket" "test-bucket-for-state" {
#   name        = "$PROJECT_ID"
#   location    = "US"
#   uniform_bucket_level_access = true
# }

# terraform {
#   backend "gcs" {
#     bucket  = "$PROJECT_ID"
#     prefix  = "terraform/state"
#   }
# }
# EOF_END

# yes | terraform init -migrate-state

# ============================ alternative ==============================
gsutil mb -b on -p $PROJECT_ID -l $REGION gs://$PROJECT_ID 

gsutil cp default.json gs://$PROJECT_ID/terraform/state/default.tfstate &
# =========================== Alternative =================================

gsutil label ch -l "key:value" gs://$PROJECT_ID & wait

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#