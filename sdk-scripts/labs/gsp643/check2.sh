
lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if  gcloud services enable iap.googleapis.com --project $PROJECT_ID; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

gcloud iap oauth-brands create \
    --application_title "Pet Theory" \
    --support_email $USER_EMAIL \
    --project $PROJECT_ID

BRAND=$(gcloud iap oauth-brands list --project $PROJECT_ID --format "value(name)")
while [ "$BRAND" = "" ]; do
    BRAND=$(gcloud iap oauth-brands list --project $PROJECT_ID --format "value(name)")
done

echo $BRAND

gcloud iap oauth-clients create $BRAND --display_name="Pet Theory" --project $PROJECT_ID --format json
