#!/bin/bash
set -eux

echo "Remove NSG rule to allow SSH from GitHub runner to VNet"
echo "Usage: ./05-nsg-remove-gh-runner-ssh-vnet.sh \$nsgName"

nsgName=$1

az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$nsgName" --name "$NSG_RULE_NAME_GH_VNET"
