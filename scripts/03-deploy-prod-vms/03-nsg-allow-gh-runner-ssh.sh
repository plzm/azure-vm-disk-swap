#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

echo "Add NSG rules to allow SSH from GitHub runner"

#../ssh/04-nsg-allow-gh-runner-ssh-vnet.sh

../ssh/06-nsg-allow-gh-runner-ssh-vm.sh "$RG_NAME_VM_PROD" "$VM_PROD_NAME_1" "$NSG_RULE_NAME_GH_PROD_VM_1" "$NSG_RULE_PRIORITY_GH_PROD_VM_1"
../ssh/06-nsg-allow-gh-runner-ssh-vm.sh "$RG_NAME_VM_PROD" "$VM_PROD_NAME_2" "$NSG_RULE_NAME_GH_PROD_VM_2" "$NSG_RULE_PRIORITY_GH_PROD_VM_2"
