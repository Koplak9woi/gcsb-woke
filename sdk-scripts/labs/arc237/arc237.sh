
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

gcloud config set project $PROJECT_ID

cd ../materials/nodejs-docs-samples/functions/v2/helloPubSub/

gcloud functions deploy cf-demo \
    --gen2 \
    --runtime=nodejs20 \
    --region=$REGION \
    --source=. \
    --entry-point=helloPubSub \
    --trigger-topic=cf_topic \
    --project $PROJECT_ID

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#