#!/bin/bash

. ./step00.variables.sh

echo "Create Key Vault"
az deployment group create --subscription "$subscriptionId" -n "KV-""$location" --verbose \
	-g "$rgNameSecurity" --template-uri "$templateKeyVault" \
	--parameters \
	location="$location" \
	tenantId="$tenantId" \
	keyVaultName="$keyVaultName" \
	skuName="$keyVaultSkuName"

echo "Grant permissions to current authentication context to get/set/list certs, secrets and keys"
# https://docs.microsoft.com/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_set_policy
az keyvault set-policy --subscription "$subscriptionId" --verbose \
	-g "$rgNameSecurity" -n "$keyVaultName" \
	--object-id "$userObjectId" \
	--key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey \
	--secret-permissions backup delete get list purge recover restore set \
	--certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update

if [ ! -z $userNameUAMI ]
then
	echo "Assign permissions to UAMI to get/set/list secrets and keys"

	# Get UAMI principal ID
	uamiPrincipalId="$(az identity show --subscription ""$subscriptionId"" -g ""$rgNameSecurity"" --name ""$userNameUAMI"" -o tsv --query 'principalId')"

	az keyvault set-policy --subscription "$subscriptionId" --verbose \
		-g "$rgNameSecurity" -n "$keyVaultName" \
		--object-id "$uamiPrincipalId" \
		--key-permissions get \
		--secret-permissions get \
		--certificate-permissions get
fi