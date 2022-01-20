#!/bin/bash

# ==================================================
# Variables
. ./step00.variables.sh
# ==================================================

# WARNING - this will delete ALL resource in all of these Resource Groups

az group delete --subscription "$subscriptionId" -n "$rgNameDeploy" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameSource" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameSecurity" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameSig" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameNet" --yes --verbose
