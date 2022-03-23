#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../ssh/05-nsg-remove-gh-runner-ssh-vnet.sh

../ssh/07-nsg-remove-gh-runner-ssh-vm.sh "$NSG_RULE_NAME_GH_SOURCE_VM_V2"
../ssh/07-nsg-remove-gh-runner-ssh-vm.sh "$NSG_RULE_NAME_GH_SOURCE_VM_V3"
