#!/bin/bash

. ./step00.variables.sh

echo "Create Resource Groups"
az group create --subscription "$subscriptionId" -n "$rgNameSecurity" -l "$location" --verbose
az group create --subscription "$subscriptionId" -n "$rgNameSig" -l "$location" --verbose
az group create --subscription "$subscriptionId" -n "$rgNameNet" -l "$location" --verbose
az group create --subscription "$subscriptionId" -n "$rgNameSource" -l "$location" --verbose
az group create --subscription "$subscriptionId" -n "$rgNameDeploy" -l "$location" --verbose
