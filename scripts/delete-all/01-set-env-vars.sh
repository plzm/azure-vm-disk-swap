#!/bin/bash

# ##################################################
# Variables only for this file - not exported to env vars

subscriptionName="Sandbox"

resourceNamingInfix="pz"

# ##################################################

# ##################################################
# Variables to export to env vars

# Subscription ID. bash/az cli started appending line feed so here we get rid of it.
export SUBSCRIPTION_ID=$(echo "$(az account show -s $subscriptionName -o tsv --query 'id')" | sed "s/\r//")

# Deployment
export LOCATION="eastus2"

# Resource Groups
export RG_NAME_SECURITY="$resourceNamingInfix""-security-""$LOCATION"
export RG_NAME_SIG="$resourceNamingInfix""-sig-""$LOCATION"
export RG_NAME_NET="$resourceNamingInfix""-net-""$LOCATION"
export RG_NAME_SOURCE="$resourceNamingInfix""-vm-source-""$LOCATION"
export RG_NAME_DEPLOY="$resourceNamingInfix""-vm-deploy-""$LOCATION"

# ##################################################
