#!/bin/bash

# WARNING - this will delete ALL resource in all of these Resource Groups

az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_DEPLOY" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SOURCE" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SECURITY" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SIG" --yes --verbose
az group delete --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_NET" --yes --verbose
