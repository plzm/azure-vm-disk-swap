#!/bin/bash

echo "Create Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-""$LOCATION" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT" \
	--parameters \
	location="$LOCATION" \
	tenantId="$TENANT_ID" \
	keyVaultName="$KEYVAULT_NAME" \
	skuName="$KEYVAULT_SKU_NAME" \
	enableSoftDelete="false"

echo "Grant permissions to current authentication context to get/set/list certs, secrets and keys"
# https://docs.microsoft.com/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_set_policy
az keyvault set-policy --subscription "$SUBSCRIPTION_ID" --verbose \
	-g "$RG_NAME_SECURITY" -n "$KEYVAULT_NAME" \
	--object-id "$USER_OBJECT_ID" \
	--key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey \
	--secret-permissions backup delete get list purge recover restore set \
	--certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update

if [ ! -z $USERNAME_UAMI ]
then
	echo "Assign permissions to UAMI to get/set/list secrets and keys"

	# Get UAMI principal ID
	uamiPrincipalId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'principalId')" | sed "s/\r//")

	az keyvault set-policy --subscription "$SUBSCRIPTION_ID" --verbose \
		-g "$RG_NAME_SECURITY" -n "$KEYVAULT_NAME" \
		--object-id "$uamiPrincipalId" \
		--key-permissions get \
		--secret-permissions get \
		--certificate-permissions get
fi