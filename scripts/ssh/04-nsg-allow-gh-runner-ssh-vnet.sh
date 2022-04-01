#!/bin/bash
set -eux

echo "Add NSG rule to allow SSH from GitHub runner to VNet"
echo "Usage: ./04-nsg-allow-gh-runner-ssh-vnet.sh \$nsgName"

nsgName=$1

az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-GitHub-VNet" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$nsgName" \
	nsgRuleName="$NSG_RULE_NAME_GH_VNET" \
	priority=$NSG_RULE_PRIORITY_GH_VNET \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="VirtualNetwork" \
	destinationPortRange="22"
