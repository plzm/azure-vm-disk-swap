#!/bin/bash


echo "Set Secret expiration date to 1 year from today - adjust as needed"
expirationDate="$(date +%s -d "$(date) + 1 year")"

#echo "Write VM Admin Username to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-""$LOCATION" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME" \
	secretValue="$DEPLOYMENT_SSH_USER_NAME" \
	expirationDate="$expirationDate"

#echo "Write VM Admin SSH Public Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-""$LOCATION" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" \
	secretValue="$ADMIN_SSH_PUBLIC_KEY" \
	expirationDate="$expirationDate"

#echo "Write New VM Admin Username to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-""$LOCATION" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" \
	secretValue="$VM_ADMIN_SSH_USER_NAME" \
	expirationDate="$expirationDate"

#echo "Write New VM Admin SSH Public Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-""$LOCATION" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" \
	secretValue="$VM_ADMIN_SSH_PUBLIC_KEY" \
	expirationDate="$expirationDate"
