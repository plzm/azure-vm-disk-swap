#!/bin/bash

# This is here for use in other scripts. This script by itself is not needed, just copy-paste from this for convenience.

vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

vmDeployUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmDeploySshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")
vmDeploySshPrivateKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PRIVATE_KEY" -o tsv --query 'value')" | sed "s/\r//")

echo $vmAdminUsername
echo $vmAdminSshPublicKey
echo $vmDeployUsername
echo $vmDeploySshPublicKey
echo $vmDeploySshPrivateKey
