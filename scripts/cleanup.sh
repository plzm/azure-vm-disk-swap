#!/bin/bash

# Cleanup SSH entries
./cleanup-ssh.sh

# WARNING - this will delete ALL resources in all of these Resource Groups
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_DEPLOY" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SOURCE" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_GALLERY" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SECURITY" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_NET" --yes --verbose
