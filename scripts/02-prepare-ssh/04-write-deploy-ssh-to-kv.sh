#!/bin/bash

# Set Key Vault Secret expiration date to 1 day from today - adjust as needed
# This deployment user credential is intended to be transient. A new one is generated each time these scripts (or pipeline steps) are run.
# So you could shorten this even more, perhaps to 1 hour. Depends on the complexity of your process.
expirationDate="$(date +%s -d "$(date) + 1 day")"

# Below we write the public AND private keys to Key Vault. The private key is only needed if it will be used again in a later deployment or other context.
# If the deployment SSH key will ONLY be used in a single context - e.g. a single pipeline execution - and will not be needed again later, the private key does not
# need to be written to Key Vault. Determine whether the private key should be persisted to Key Vault based on your circumstances and constraints.

# Read keys from file into variables - this assumes the key files are in current dir as created in a previous step
DEPLOYMENT_SSH_PRIVATE_KEY=$(<$DEPLOYMENT_SSH_USER_KEY_NAME)
#echo $DEPLOYMENT_SSH_PRIVATE_KEY # Obviously be very careful uncommenting this line in a build agent context... here for local debug.
DEPLOYMENT_SSH_PUBLIC_KEY=$(<"$DEPLOYMENT_SSH_USER_KEY_NAME"".pub")
#echo $DEPLOYMENT_SSH_PUBLIC_KEY

#echo "Write Deployment Username to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-Deploy-Username" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME" \
	secretValue="$DEPLOYMENT_SSH_USER_NAME" \
	expirationDate="$expirationDate"

#echo "Write Deployment User SSH Public Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-Deploy-PubKey" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" \
	secretValue="$DEPLOYMENT_SSH_PUBLIC_KEY" \
	expirationDate="$expirationDate"

#echo "Write Deployment User SSH Private Key to Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-Deploy-PrivKey" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT_SECRET" \
	--parameters \
	location="$LOCATION" \
	keyVaultName="$KEYVAULT_NAME" \
	secretName="$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PRIVATE_KEY" \
	secretValue="$DEPLOYMENT_SSH_PRIVATE_KEY" \
	expirationDate="$expirationDate"
