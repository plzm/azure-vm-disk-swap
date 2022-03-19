#!/bin/bash
set -eux

echo "Create Resource Groups"
az group create --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_DEPLOY" -l "$LOCATION" --verbose
