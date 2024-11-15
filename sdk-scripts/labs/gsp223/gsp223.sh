#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp223

gsutil mb -p $PROJECT_ID \
    -c standard    \
    -l us \
    gs://$PROJECT_ID-vcm/

export BUCKET="${PROJECT_ID}-vcm"

gsutil -m cp -r gs://spls/gsp223/images/* gs://${BUCKET} &

gsutil cp gs://spls/gsp223/data.csv . 

sed -i -e "s/placeholder/${BUCKET}/g" ./data.csv

gsutil cp ./data.csv gs://${BUCKET}

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#