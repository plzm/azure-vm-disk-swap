#!/bin/bash
set -eux

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../vmadmin/delete-user-with-azure-cli.sh "$RG_NAME_VM_SOURCE" "$VM_SRC_NAME_VNEXT" "$DEPLOYMENT_SSH_USER_NAME"
