#!/bin/bash

echo "Add NSG rule to allow SSH from GitHub runner to VNet"

az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-GitHub-VNet" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="$NSG_RULE_NAME_GH_VNET" \
	priority=$NSG_RULE_PRIORITY_GH_VNET \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="VirtualNetwork" \
	destinationPortRange="22"
