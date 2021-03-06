#!/bin/bash
set +e

# WARNING - this will delete ALL resources in all of these Resource Groups
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_VM_PROD" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_VM_SOURCE" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_GALLERY" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SECURITY" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_NET" --yes --verbose
