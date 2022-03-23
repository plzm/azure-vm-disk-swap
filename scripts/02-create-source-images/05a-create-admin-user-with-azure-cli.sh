#!/bin/bash
set -eux

echo "Add admin user and public SSH key to v2 VM"
az vm user update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_SOURCE" --verbose \
	-n "$VM_SRC_NAME_V2" --username "$VM_ADMIN_SSH_USER_NAME" --ssh-key-value "$VM_ADMIN_SSH_PUBLIC_KEY"

echo "Add admin user and public SSH key to v3 VM"
az vm user update --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_SOURCE" --verbose \
	-n "$VM_SRC_NAME_V3" --username "$VM_ADMIN_SSH_USER_NAME" --ssh-key-value "$VM_ADMIN_SSH_PUBLIC_KEY"
