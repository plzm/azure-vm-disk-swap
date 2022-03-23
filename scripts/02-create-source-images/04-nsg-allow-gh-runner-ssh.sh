#!/bin/bash

../ssh/04-nsg-allow-gh-runner-ssh-vnet.sh

../ssh/06-nsg-allow-gh-runner-ssh-vm.sh "$RG_NAME_VM_SOURCE" "$VM_SRC_NAME_V2" "$NSG_RULE_NAME_GH_SOURCE_VM_V2" "$NSG_RULE_PRIORITY_GH_SOURCE_VM_V2"
../ssh/06-nsg-allow-gh-runner-ssh-vm.sh "$RG_NAME_VM_SOURCE" "$VM_SRC_NAME_V3" "$NSG_RULE_NAME_GH_SOURCE_VM_V3" "$NSG_RULE_PRIORITY_GH_SOURCE_VM_V3"
