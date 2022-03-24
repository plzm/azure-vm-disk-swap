#!/bin/bash
set -eux

#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

echo "Remove NSG rules to allow SSH from GitHub runner"

../ssh/05-nsg-remove-gh-runner-ssh-vnet.sh

../ssh/07-nsg-remove-gh-runner-ssh-vm.sh "$NSG_RULE_NAME_GH_PROD_VM_1"
../ssh/07-nsg-remove-gh-runner-ssh-vm.sh "$NSG_RULE_NAME_GH_PROD_VM_2"
