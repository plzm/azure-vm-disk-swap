#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

./01-deploy-rgs.sh
../ssh/01-prepare-local-keys.sh
./02-deploy-prod-vm.sh
../ssh/04-nsg-allow-gh-runner-ssh-vnet.sh
./03-create-admin-user.sh
./04-configure-prod-vm.sh
./05-delete-deploy-user.sh
az vm deallocate --subscription "${{ env.SUBSCRIPTION_ID }}" -g "${{ env.RG_NAME_VM_PROD }}" --name "${{ env.VM_PROD_NAME_1 }}" --verbose
../ssh/05-nsg-remove-gh-runner-ssh-vnet.sh
../ssh/02-cleanup-local-keys.sh
../ssh/03-cleanup-known-hosts.sh
