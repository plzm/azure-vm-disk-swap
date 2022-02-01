#!/bin/bash

echo "Retrieve new Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT was only to put them INTO Key Vault in step04.
vmNewAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_NEW_ADMIN_USERNAME" -o tsv --query 'value')" | sed "s/\r//")
vmNewAdminUserSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_NEW_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

echo "Create a new admin user"
# https://docs.microsoft.com/cli/azure/vm/user?view=azure-cli-latest#az_vm_user_update
# This installs and uses the VMAccess extension. If that extension is not permissible in your environment, consider step13 option 1 instead,
# which uses the custom script extension.
az vm user update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --verbose \
	-n "$VM_NAME_DEPLOY_1" --username "$vmNewAdminUsername" --ssh-key-value "$vmNewAdminUserSshPublicKey"
