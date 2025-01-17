#!/bin/bash

export BLACK=`tput setaf 0`
export RED=`tput setaf 1`
export GREEN=`tput setaf 2`
export YELLOW=`tput setaf 3`
export BLUE=`tput setaf 4`
export MAGENTA=`tput setaf 5`
export CYAN=`tput setaf 6`
export WHITE=`tput setaf 7`
export BG_BLACK=`tput setab 0`
export BG_RED=`tput setab 1`
export BG_GREEN=`tput setab 2`
export BG_YELLOW=`tput setab 3`
export BG_BLUE=`tput setab 4`
export BG_MAGENTA=`tput setab 5`
export BG_CYAN=`tput setab 6`
export BG_WHITE=`tput setab 7`
export BOLD=`tput bold`
export RESET=`tput sgr0`

# CLEAR ALL SESSION
gcloud auth revoke --all

# Use this If NodeJS is installed on the system where you run the script
node browser-automation.js &

# Use this If NodeJS is installed on Windows but you're using WSL to run the script.
# Please ensure it's set to your NodeJS path.
# export node="/mnt/c/Program Files/nodejs/node.exe"
# "$node" browser-automation.js &


# INITIALIZING GOOGLE CLOUD SDK
# ./autoinit.sh       # Disable this if your system doesn't support "expect" command
gcloud init --skip-diagnostics
gcloud auth login   # Faster Initialization

# Use Below to create Credential for Workspace API
# yes | gcloud auth application-default login \
#     --scopes=openid,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/bigquery,https://www.googleapis.com/auth/script.projects

# DECLARE VARIABLES
while IFS='=' read -ra line; do
    key=${line[0]}
    value=${line[1]}
    declare "$key"="$value"
    export "$key"
done < tmp/variables.txt

# Define GCP Variables
export GOOGLE_CLOUD_PROJECT=$PROJECT_ID
export GOOGLE_CLOUD_QUOTA_PROJECT=$PROJECT_ID
export USER_NAME=$(echo $USER_EMAIL | grep -oE "(student[-a-z0-9]+)")
export GOOGLE_APPLICATION_CREDENTIALS="/home/aguzztn54/.config/gcloud/legacy_credentials/$USER_EMAIL/adc.json"

# Use this for Application Default Credential Auth
# export GOOGLE_APPLICATION_CREDENTIALS="/home/aguzztn54/.config/gcloud/application_default_credentials.json"

# REPlACE WITH YOUR LAB ID
LABID="gsp072"   # example => gsp016

./labs/${LABID}/${LABID}.sh