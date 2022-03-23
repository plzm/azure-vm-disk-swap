#!/bin/bash

echo "Remove NSG rule to allow SSH from GitHub runner to VM"
echo "Usage: ./07-nsg-remove-gh-runner-ssh-vm.sh \$nsgRuleName"

nsgRuleName=$1

echo "Remove NSG rule for GitHub runner inbound access to VM v2"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$nsgRuleName"
