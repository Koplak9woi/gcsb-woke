
#   ============================= TASK 2 =================================
gcloud firestore databases create \
    --location=$REGION \
    --type=firestore-native

gcloud firestore indexes composite create \
    --collection-group=images \
    --field-config field-path=thumbnail,order=descending \
    --field-config field-path=created,order=descending \
    --async