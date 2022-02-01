#!/bin/bash

echo "Create Azure Compute Gallery"
# https://docs.microsoft.com/cli/azure/sig?view=azure-cli-latest#az_sig_create
az sig create --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SIG" -l "$LOCATION" --verbose \
	--gallery-name "$SIG_NAME" --soft-delete false
