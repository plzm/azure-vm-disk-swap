#!/bin/bash

# Set Key Vault Secret expiration date to 1 year from today - adjust as needed
# This admin user credential is not intended to be transient. It is not actually generated as part of these scripts/steps, and the private key is (by design) not even known here.
# You can adjust this expiration date as needed or not even include this step in your pipeline, if you have a separate/external
# process to provision an admin SSH private key. If you do not need/use this script/step, adjust the admin public key to use correctly in env var setup.

expirationDate="$(date +%s -d "$(date) + 1 year")"

#echo "Write VM Admin Username to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-VM-Admin-Username" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" \
	secretValue="$VM_ADMIN_SSH_USER_NAME" \
	expirationDate="$expirationDate"

#echo "Write VM Admin User SSH Public Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-VM-Admin-PubKey" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" \
	secretValue="$VM_ADMIN_SSH_PUBLIC_KEY" \
	expirationDate="$expirationDate"
