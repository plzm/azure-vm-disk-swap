#!/bin/bash
set -eux

## SIGSoftDelete currently in preview
# az feature register --subscription "$SUBSCRIPTION_ID" --namespace Microsoft.Compute --name SIGSoftDelete
## Run following until Registered
# az feature show --subscription "$SUBSCRIPTION_ID" --namespace Microsoft.Compute --name SIGSoftDelete
## Then run
# az provider register --subscription "$SUBSCRIPTION_ID" -n Microsoft.Compute


echo "Create Azure Compute Gallery"
# https://docs.microsoft.com/cli/azure/sig?view=azure-cli-latest#az_sig_create
#az sig create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_GALLERY" -l "$LOCATION" --verbose \
#	--gallery-name "$GALLERY_NAME" # --soft-delete false

az deployment group create --subscription "$SUBSCRIPTION_ID" -n "CG-""$LOCATION" --verbose \
	-g "$RG_NAME_GALLERY" --template-uri "$TEMPLATE_COMPUTE_GALLERY" \
	--parameters \
	location="$LOCATION" \
	gallery-name="$GALLERY_NAME" \
	softDeleteEnabled=false
