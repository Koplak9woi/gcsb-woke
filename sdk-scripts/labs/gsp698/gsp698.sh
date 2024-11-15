
export CAI_BUCKET_NAME=cai-$PROJECT_ID

enable_service(){
    gcloud services enable cloudasset.googleapis.com --project $PROJECT_ID
}

lib_enabled=false
while [ "$lib_enabled" = false ]; do
	if enable_service; then
		echo "API ENABLED, continuing.."
		lib_enabled=true
	else
		echo "Retrying to Enable Required APIs..."
	fi
done


gcloud beta services identity create --service=cloudasset.googleapis.com --project=$PROJECT_ID

PROJECT_NUMBER=$(gcloud projects list \
    --filter="$PROJECT_ID" \
    --format="value(PROJECT_NUMBER)" \
    --project=$PROJECT_ID)
    
gcloud projects add-iam-policy-binding ${PROJECT_ID}  \
   --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-cloudasset.iam.gserviceaccount.com \
   --role=roles/storage.admin \
   --project=$PROJECT_ID

# git clone https://github.com/forseti-security/policy-library.git

# cp policy-library/samples/storage_denylist_public.yaml policy-library/policies/constraints/

gsutil mb -l $REGION -p $PROJECT_ID gs://$CAI_BUCKET_NAME


# Export resource data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/resource_inventory.json \
    --content-type=resource \
    --project=$PROJECT_ID

# Export IAM data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/iam_inventory.json \
    --content-type=iam-policy \
    --project=$PROJECT_ID

# Export org policy data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/org_policy_inventory.json \
    --content-type=org-policy \
    --project=$PROJECT_ID

# Export access policy data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/access_policy_inventory.json \
    --content-type=access-policy \
    --project=$PROJECT_ID
