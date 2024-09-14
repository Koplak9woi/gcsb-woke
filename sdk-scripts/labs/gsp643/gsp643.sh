#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

echo "Please Open https://console.firebase.google.com/project/$PROJECT_ID and accept TOS"

cd ./labs/gsp643

./check2.sh &

cd ./source

export TOKEN=$(gcloud auth print-access-token --project $PROJECT_ID)

cp $GOOGLE_APPLICATION_CREDENTIALS ./adc.json

cat > .env <<EOF_CP
GOOGLE_CLOUD_PROJECT=$PROJECT_ID
GOOGLE_APPLICATION_CREDENTIALS=adc.json
EOF_CP

cat > customers.csv <<EOF_END
id,name,email,phone
57551,John,$USER_EMAIL,98473757454
EOF_END

"$node" import.js customers.csv &

app_created=false
while [ "$app_created" = false ]; do
    http_code=$(curl -o /dev/null -s -w "%{http_code}\n" \
        -X POST \
        -H 'Cache-Control: no-cache, no-store' \
        -H "Content-Type: application/json" \
        -H "x-goog-user-project: $PROJECT_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{"displayName": "Pet Theory"}' \
        "https://firebase.googleapis.com/v1beta1/projects/$PROJECT_ID/webApps")

    echo $http_code;

    if [ "$http_code" = "200" ]; then
        echo "Firebase App Creation Success"
        app_created=true
    else
        echo "Please Open https://console.firebase.google.com/project/$PROJECT_ID and accept TOS"
    fi
done

echo "Mantab" & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#