
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp499

enable_api() {
    gcloud services enable iap.googleapis.com appengineflex.googleapis.com --project $PROJECT_ID
}

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if enable_api; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done


# gsutil cp gs://spls/gsp499/user-authentication-with-iap.zip .

# unzip user-authentication-with-iap.zip

# cd user-authentication-with-iap

./app1.sh
./app2-3.sh &

# LINK=$(gcloud app browse)

# DOMAIN=${LINK#https://}

# cat > details.json << EOF
# {
#   App name: IAP Example
#   Application home page: $LINK
#   Application privacy Policy link: $LINK/privacy
#   Authorized domains: $DOMAIN
#   Developer Contact Information: $USER_EMAIL
# }
# EOF

# cat details.json

gcloud iap oauth-brands create \
    --application_title "IAP Example" \
    --support_email $USER_EMAIL \
    --project $PROJECT_ID

BRAND=$(gcloud iap oauth-brands list --project $PROJECT_ID --format "value(name)")
IAP_CLIENT=$(gcloud iap oauth-clients list $BRAND --project $PROJECT_ID --format json)

CLIENT_SECRET=$(echo $IAP_CLIENT | jq '.[0].secret')
CLIENT_ID=$(echo $IAP_CLIENT | jq '.[0].name' | grep -oE '([0-9]+)-([0-9a-zA-Z].+)(.com)')

gcloud iap web enable \
    --resource-type app-engine \
    --oauth2-client-id $CLIENT_ID \
    --oauth2-client-secret $CLIENT_SECRET \
    --project $PROJECT_ID

gcloud iap web add-iam-policy-binding \
    --project $PROJECT_ID \
    --member $USER_EMAIL \
    --role roles/iap.httpsResourceAccessor

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#