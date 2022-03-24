#!/bin/bash

echo "Create Resource Groups"
az group create --subscription "$SUBSCRIPTION_ID" -n "$RG_NAME_VM_SOURCE" -l "$LOCATION" --verbose
