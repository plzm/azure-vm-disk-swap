#!/bin/bash

echo "Create Resource Groups"
az group create --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SECURITY" -l "$LOCATION" --verbose
az group create --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SIG" -l "$LOCATION" --verbose
az group create --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_NET" -l "$LOCATION" --verbose
az group create --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_SOURCE" -l "$LOCATION" --verbose
az group create --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_DEPLOY" -l "$LOCATION" --verbose
