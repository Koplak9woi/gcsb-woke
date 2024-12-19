gsutil mb -p $PROJECT_ID gs://$PROJECT_ID
gsutil cp config.yaml gs://$PROJECT_ID
# gsutil -m acl set -R -a public-read gs://$PROJECT_ID