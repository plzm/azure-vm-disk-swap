#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../set-env-vars.sh
./01-deploy-rgs.sh
../ssh/01-prepare-local-keys.sh
./02-create-image-definition.sh
./03-deploy-source-vm.sh
../ssh/04-nsg-allow-gh-runner-ssh-vnet.sh "$NSG_NAME_SOURCE"
./04-prepare-vm-for-capture.sh
./05-capture-vm.sh
../ssh/05-nsg-remove-gh-runner-ssh-vnet.sh "$NSG_NAME_SOURCE"
../ssh/02-cleanup-local-keys.sh
../ssh/03-cleanup-known-hosts.sh
./06-cleanup.sh
