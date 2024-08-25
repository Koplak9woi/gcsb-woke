
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp290

enable_lib(){
    gcloud services disable dataflow.googleapis.com --project $PROJECT_ID
    gcloud services enable dataflow.googleapis.com --project $PROJECT_ID
}

lib_enabled=false
while [ "$lib_enabled" = false ]; do
    if enable_lib; then
        echo "Required Library Enabled"
        lib_enabled=true
    else
        echo "Re-trying to enable required APIs..."
    fi
done

# gsutil -m cp -R gs://spls/gsp290/dataflow-python-examples .

# gcloud config set project $PROJECT_ID

bq mk --project_id $PROJECT_ID lake &

gsutil mb -p $PROJECT_ID -c "regional" -l $REGION  gs://$PROJECT_ID

gsutil cp gs://spls/gsp290/data_files/usa_names.csv gs://$PROJECT_ID/data_files/

gsutil cp gs://spls/gsp290/data_files/head_usa_names.csv gs://$PROJECT_ID/data_files/


# virtualenv -p python3 vrenv

source vrenv/bin/activate

# pip install apache-beam[gcp]==2.24.0

cd dataflow/

python dataflow_python_examples/data_ingestion.py \
  --project=$PROJECT_ID --region=$REGION \
  --runner=DataflowRunner \
  --staging_location=gs://$PROJECT_ID/test \
  --temp_location gs://$PROJECT_ID/test \
  --input gs://$PROJECT_ID/data_files/head_usa_names.csv \
  --save_main_session &

python dataflow_python_examples/data_transformation.py \
  --project=$PROJECT_ID \
  --region=$REGION \
  --runner=DataflowRunner \
  --staging_location=gs://$PROJECT_ID/test \
  --temp_location gs://$PROJECT_ID/test \
  --input gs://$PROJECT_ID/data_files/head_usa_names.csv \
  --save_main_session &

sed -i "s/values = \[x.decode('utf8') for x in csv_row\]/values = \[x for x in csv_row\]/" ./dataflow_python_examples/data_enrichment.py

python dataflow_python_examples/data_enrichment.py \
  --project=$PROJECT_ID \
  --region=$REGION \
  --runner=DataflowRunner \
  --staging_location=gs://$PROJECT_ID/test \
  --temp_location gs://$PROJECT_ID/test \
  --input gs://$PROJECT_ID/data_files/head_usa_names.csv \
  --save_main_session &

python dataflow_python_examples/data_lake_to_mart.py \
  --worker_disk_type="compute.googleapis.com/projects//zones//diskTypes/pd-ssd" \
  --max_num_workers=4 \
  --project=$PROJECT_ID \
  --runner=DataflowRunner \
  --staging_location=gs://$PROJECT_ID/test \
  --temp_location gs://$PROJECT_ID/test \
  --save_main_session \
  --region=$REGION & wait

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#