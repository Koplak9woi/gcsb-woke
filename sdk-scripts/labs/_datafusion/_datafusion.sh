#!/bin/bash

echo "${BLUE}${BOLD}Exporting project information...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)

echo "${CYAN}${BOLD}Creating a Cloud Storage bucket...${RESET}"
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")

echo "${BLUE}${BOLD}Adding IAM policy bindings...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
    --role="roles/project.editor"

gcloud beta data-fusion instances create my-instance --project=$PROJECT_ID --location=us-central1 --edition=basic --enable_stackdriver_logging

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/datafusion.apiservice.agent"

