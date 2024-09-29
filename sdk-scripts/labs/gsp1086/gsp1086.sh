#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

export REGION="${ZONE%-*}"

cd ./labs/gsp1086

gcloud alloydb instances create lab-instance-rp1 \
    --cluster=lab-cluster \
    --region=$REGION \
    --instance-type=READ_POOL \
    --cpu-count=2 \
    --read-pool-node-count=2 \
    --project=$PROJECT_ID &

gcloud beta alloydb backups create lab-backup \
    --region=$REGION \
    --cluster=lab-cluster \
    --project=$PROJECT_ID &

export ALLOYDB=$(gcloud beta alloydb instances describe lab-instance \
    --cluster lab-cluster \
    --region $REGION \
    --project $PROJECT_ID \
    --format 'value(ipAddress)')


ssh_connect(){
    gcloud compute ssh $USER_NAME@alloydb-client \
        --project=$PROJECT_ID \
        --zone=$ZONE \
        --command=<<EOF_END
echo $ALLOYDB > alloydbip.txt

echo $ALLOYDB:5432:postgres:postgres:Change3Me > .pgpass
chmod u-x,go-rwx .pgpass
cat .pgpass

psql -h $ALLOYDB -U postgres -w <<EOF
\c postgres
CREATE EXTENSION IF NOT EXISTS PGAUDIT;
select extname, extversion from pg_extension where extname = 'pgaudit';
EOF
EOF_END
}

success=false
while [ "$success" = false ]; do
  if ssh_connect; then
    echo "SSH Connection Success, Executing Commands"
    success=true
  else
    echo "Waiting for Connections"
  fi
done

echo 'mantab'

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#