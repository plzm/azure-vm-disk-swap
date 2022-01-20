#!/bin/bash

. ./step00.variables.sh

# Expiration date in 1 year from "today" - adust as needed
expirationDate="$(date +%s -d "$(date) + 1 year")"

#echo "Write VM Admin Username to Key Vault"
az deployment group create --subscription "$subscriptionId" -n "KV-""$location" --verbose \
	-g "$rgNameSecurity" --template-uri "$templateKeyVaultSecret" \
	--parameters \
	location="$location" \
	keyVaultName="$keyVaultName" \
	secretName="$keyVaultSecretNameAdminUsername" \
	secretValue="$adminUsername" \
	expirationDate="$expirationDate"

#echo "Write VM Admin SSH Public Key to Key Vault"
az deployment group create --subscription "$subscriptionId" -n "KV-""$location" --verbose \
	-g "$rgNameSecurity" --template-uri "$templateKeyVaultSecret" \
	--parameters \
	location="$location" \
	keyVaultName="$keyVaultName" \
	secretName="$keyVaultSecretNameAdminSshPublicKey" \
	secretValue="$adminSshPublicKey" \
	expirationDate="$expirationDate"

#echo "Write New VM Admin Username to Key Vault"
az deployment group create --subscription "$subscriptionId" -n "KV-""$location" --verbose \
	-g "$rgNameSecurity" --template-uri "$templateKeyVaultSecret" \
	--parameters \
	location="$location" \
	keyVaultName="$keyVaultName" \
	secretName="$keyVaultSecretNameNewAdminUsername" \
	secretValue="$newAdminUsername" \
	expirationDate="$expirationDate"

#echo "Write New VM Admin SSH Public Key to Key Vault"
az deployment group create --subscription "$subscriptionId" -n "KV-""$location" --verbose \
	-g "$rgNameSecurity" --template-uri "$templateKeyVaultSecret" \
	--parameters \
	location="$location" \
	keyVaultName="$keyVaultName" \
	secretName="$keyVaultSecretNameNewAdminSshPublicKey" \
	secretValue="$newAdminSshPublicKey" \
	expirationDate="$expirationDate"
