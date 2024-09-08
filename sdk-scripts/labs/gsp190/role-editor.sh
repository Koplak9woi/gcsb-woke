echo 'description: Edit access for App Versions
etag:
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
name: projects/'$PROJECT_ID'/roles/editor
stage: ALPHA
title: Role Editor' > new-role-definition.yaml


gcloud iam roles create editor \
    --project $PROJECT_ID \
    --file new-role-definition.yaml

# gcloud iam roles update editor \
#     --project $PROJECT_ID \
#     --file new-role-definition.yaml