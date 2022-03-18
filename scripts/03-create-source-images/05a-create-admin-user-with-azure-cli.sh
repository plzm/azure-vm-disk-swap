#!/bin/bash

echo "Retrieve VM Admin Username and SSH Public Key from Key Vault"
vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

echo "Add admin user and public SSH key to v2 VM"
az vm user update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --verbose \
	-n "$VM_SRC_NAME_V2" --username "$vmAdminUsername" --ssh-key-value "$vmAdminSshPublicKey"

echo "Add admin user and public SSH key to v3 VM"
az vm user update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_SOURCE" --verbose \
	-n "$VM_SRC_NAME_V3" --username "$vmAdminUsername" --ssh-key-value "$vmAdminSshPublicKey"
