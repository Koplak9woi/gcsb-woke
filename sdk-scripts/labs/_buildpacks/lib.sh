
enable_lib(){
	gcloud services enable run.googleapis.com \
		artifactregistry.googleapis.com \
		translate.googleapis.com \
        --project $PROJECT_ID
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