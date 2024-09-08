
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp1005

gsutil cp db_name.txt gs://$PROJECT_ID &
gsutil cp username.txt gs://$PROJECT_ID &
gsutil cp password.txt gs://$PROJECT_ID & wait


echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#