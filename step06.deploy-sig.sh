#!/bin/bash

. ./step00.variables.sh

echo "Create Azure Compute Gallery"
# https://docs.microsoft.com/cli/azure/sig?view=azure-cli-latest#az_sig_create
az sig create --subscription "$subscriptionId" -g "$rgNameSig" -l "$location" --verbose \
	-r "$sigName"
