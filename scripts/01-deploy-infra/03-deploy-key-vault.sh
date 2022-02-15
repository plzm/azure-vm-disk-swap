#!/bin/bash

echo "Create Key Vault"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "KV-""$LOCATION" --verbose \
	-g "$RG_NAME_SECURITY" --template-uri "$TEMPLATE_KEYVAULT" \
	--parameters \
	location="$LOCATION" \
	tenantId="$TENANT_ID" \
	keyVaultName="$KEYVAULT_NAME" \
	skuName="$KEYVAULT_SKU_NAME" \
	enableSoftDelete="$KEYVAULT_SOFT_DELETE"
