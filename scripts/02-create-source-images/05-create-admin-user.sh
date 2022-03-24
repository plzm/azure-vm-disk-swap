#!/bin/bash
set -eux

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../vmadmin/create-user-with-azure-cli.sh "$RG_NAME_VM_SOURCE" "$VM_SRC_NAME_V2" "$VM_ADMIN_SSH_USER_NAME" "$VM_ADMIN_SSH_PUBLIC_KEY"
../vmadmin/create-user-with-azure-cli.sh "$RG_NAME_VM_SOURCE" "$VM_SRC_NAME_V3" "$VM_ADMIN_SSH_USER_NAME" "$VM_ADMIN_SSH_PUBLIC_KEY"
