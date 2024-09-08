# ==== Manual Run ==========
# STEPS : 
# 1. Install Vault
# 2. Delete folder & files from vault/data
# 3. Run Vault Server in the 1st terminal

# export DBUS_SESSION_BUS_ADDRESS=/dev/null
# vault server -config=config.hcl

# 4. Open new Terminal and run
# export DBUS_SESSION_BUS_ADDRESS=/dev/null
# export VAULT_ADDR='http://127.0.0.1:8200'
# vault operator init

# Unseal Key 1: LvHi+eF2ICvgYkacUc27tULiSPaEYUTQ1gNb1WGcUt8M
# Unseal Key 2: gNgGrvjFUximYgoEo1pxe1C5RsLAzNoJRg6Dw1WMOh7F
# Unseal Key 3: LamIIt5vIKD1DtNpCFkRz1U4QDCuJFhJcERkIcpnAeel
# Unseal Key 4: ME9sIeZjowi5bIROnX08qyVyEaDL9O97wKuuoRDZs48j
# Unseal Key 5: YDbQOdWFHaIgPu2M8gKOiHyyFZKnGGuPlGSac3+4x/vz

# Initial Root Token: hvs.AklTfaucfEU2ErnadXBcphXg

# vault operator unseal (Unseal 3 token)
# vault login INITIAL_ROOT_TOKEN
# vault secrets enable gcp

# ==================================

#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

cd ./labs/gsp1007

# ================================ CHECK 1 ================================
SERVICE_ACCOUNT=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com

gcloud iam service-accounts keys create key.json \
    --project $PROJECT_ID \
    --iam-account $SERVICE_ACCOUNT

vault write gcp/config \
    credentials=@key.json \
    ttl=3600 \
    max_ttl=86400

cat > bindings.hcl << EOM
resource "buckets/$PROJECT_ID" {
  roles = [
    "roles/storage.objectAdmin",
    "roles/storage.legacyBucketReader",
  ]
}
EOM

# ========================== CHECK 2 =============================

vault write gcp/roleset/my-token-roleset \
    project="$PROJECT_ID" \
    secret_type="access_token"  \
    token_scopes="https://www.googleapis.com/auth/cloud-platform" \
    bindings=@bindings.hcl
    
# ================================ CHECK 3 ============================

vault write gcp/roleset/my-key-roleset \
    project="$PROJECT_ID" \
    secret_type="service_account_key"  \
    bindings=@bindings.hcl

vault read gcp/roleset/my-key-roleset/key &

# ================================ CHECK 4 ============================

vault write gcp/static-account/my-token-account \
    service_account_email="$SERVICE_ACCOUNT" \
    secret_type="access_token"  \
    token_scopes="https://www.googleapis.com/auth/cloud-platform" \
    bindings=@bindings.hcl &

vault write gcp/static-account/my-key-account \
    service_account_email="$SERVICE_ACCOUNT" \
    secret_type="service_account_key"  \
    bindings=@bindings.hcl & wait

    
echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#