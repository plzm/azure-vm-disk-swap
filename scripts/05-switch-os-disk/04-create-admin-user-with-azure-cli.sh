#!/bin/bash

echo "Retrieve VM Admin Username and SSH Public Key from Key Vault"
vmAdminSshUserName=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

echo "Create a new admin user"
# https://docs.microsoft.com/cli/azure/vm/user?view=azure-cli-latest#az_vm_user_update
# This installs and uses the VMAccess extension. If that extension is not permissible in your environment,
# consider using the custom script extension.
az vm user update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM_NAME_DEPLOY_1" --username "$vmAdminSshUserName" --ssh-key-value "$vmAdminSshPublicKey"
