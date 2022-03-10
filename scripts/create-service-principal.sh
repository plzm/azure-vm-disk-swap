#!/bin/bash

# This script is provided so you can create an Azure Service Principal (SP) and copy its output to a Github repo secret.
# This SP will be used to execute Azure commands in workflows.

subscriptionName="Sandbox"
subscriptionId=$(echo "$(az account show -s $subscriptionName -o tsv --query 'id')" | sed "s/\r//")
#echo $subscriptionId | cat -v

servicePrincipalName="VmDiskSwapSp"

# Create a Service Principal with Owner role on the subscription
az ad sp create-for-rbac --name $servicePrincipalName --role Owner --scopes /subscriptions/$subscriptionId --verbose --sdk-auth

# Capture the output of the above to a GitHub repo secret named AZURE_CREDENTIALS

# Also capture the clientId (=objectId) to a GitHub repo secret named SP_OBJECT_ID.
# This is needed to set KeyVault access policy for SP when running in a GHA context, as az ad show- signed-in-user crashes for an SP and there is not another way right now of getting the clientId of the current user when current is an SP.
