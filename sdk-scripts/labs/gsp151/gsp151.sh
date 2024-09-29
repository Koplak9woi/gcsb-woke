# export ZONE=
echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

gcloud sql instances create myinstance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-4 \
  --zone=$ZONE \
  --project $PROJECT_ID \
  --storage-size=100GB \
  --storage-auto-increase 

# ================== TASK 2 =====================
gcloud sql databases create guestbook --instance myinstance --project $PROJECT_ID


echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"
