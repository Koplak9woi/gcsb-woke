
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/arc133
cd ./module

TOKEN=$(gcloud auth application-default print-access-token --project $PROJECT_ID)
echo $TOKEN

service_enabled=false
while [ "$service_enabled" = false ]; do
    http_code=$(curl -o /dev/null -s -w "%{http_code}\n" \
        -X POST \
        -H 'Cache-Control: no-cache, no-store' \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: $PROJECT_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{"serviceIds": ["drive.googleapis.com", "sheets.googleapis.com", "script.googleapis.com"] }' \
        "https://serviceusage.googleapis.com/v1/projects/$PROJECT_ID/services:batchEnable")

    echo $http_code;

    if [ "$http_code" = "200" ]; then
        echo "API Enabled"
        service_enabled=true
    else
        echo "Please Open https://console.cloud.google.com/terms/universal and accept TOS"
    fi
done

cp $GOOGLE_APPLICATION_CREDENTIALS ./adc.json
cat > .env <<EOF_CP
GOOGLE_CLOUD_PROJECT=$PROJECT_ID
GOOGLE_CLOUD_QUOTA_PROJECT=$PROJECT_ID
GOOGLE_APPLICATION_CREDENTIALS=adc.json
EOF_CP

"$node" runner.js


echo "${BG_GREEN}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
