#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

./01-deploy-rgs.sh
../ssh/01-prepare-local-keys.sh
./02-deploy-prod-vm.sh
../ssh/04-nsg-allow-gh-runner-ssh-vnet.sh "$NSG_NAME_PROD"
./03-create-admin-user.sh
./04-configure-prod-vm.sh
./05-delete-deploy-user.sh
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" --name "$VM_PROD_NAME_1" --verbose
../ssh/05-nsg-remove-gh-runner-ssh-vnet.sh "$NSG_NAME_PROD"
../ssh/02-cleanup-local-keys.sh
../ssh/03-cleanup-known-hosts.sh
