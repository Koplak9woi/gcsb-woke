# Deploying a Containerized Application on Cloud Run

# ============================================== TASK 1 ===========================================
enable_lib(){
    gcloud services enable artifactregistry.googleapis.com \
        cloudbuild.googleapis.com \
        run.googleapis.com \
        --project $PROJECT_ID
}

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if enable_lib; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done


# ============================= TASK 2 =====================================

# gsutil cp gs://cloud-training/CBL515/sample-apps/sample-node-app.zip . && unzip sample-node-app

# =============================== TASK 3 =================================
cd ./labs/_ctrrun/sample-node-app

create_repo(){
    gcloud artifacts repositories create my-repo \
        --location="$REGION" \
        --repository-format=Docker \
        --project $PROJECT_ID
}

repo_created=false
while [ "$repo_created" = false ]; do
    if create_repo; then
        echo "Repository Created"
        repo_created=true
    else
        echo "Re-trying to Create Repository..."
    fi
done



yes | gcloud auth configure-docker ${REGION}-docker.pkg.dev --project $PROJECT_ID

REPO=${REGION}-docker.pkg.dev/${PROJECT_ID}/my-repo

cat > cloudbuild.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: [ 'build', '-t', '${REPO}/sample-node-app-image', '.' ]
images:
- '${REPO}/sample-node-app-image'
EOF

gcloud builds submit --region=$REGION --config=cloudbuild.yaml --project $PROJECT_ID &

# ============================= TASK 4 ===================================

gcloud run deploy sample-node-app \
    --region $REGION \
    --project $PROJECT_ID \
    --allow-unauthenticated \
    --image us-docker.pkg.dev/cloudrun/container/hello  # ${REPO}/sample-node-app-image 

# ============================== TASK 5 =================================

export URL=$(gcloud run services list --format='value(URL)' --project $PROJECT_ID)

curl $URL
curl $URL/service/products
curl $URL/service/products
