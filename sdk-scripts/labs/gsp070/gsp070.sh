gcloud services enable appengine.googleapis.com

sleep 10

gcloud config set compute/region $REGION

git clone https://github.com/GoogleCloudPlatform/golang-samples.git

cd golang-samples/appengine/go11x/helloworld

gcloud app deploy