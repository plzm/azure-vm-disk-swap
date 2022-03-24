#!/bin/bash
set -eux

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../vmadmin/delete-user-with-azure-cli.sh "$RG_NAME_VM_PROD" "$VM_PROD_NAME_1" "$DEPLOYMENT_SSH_USER_NAME"
