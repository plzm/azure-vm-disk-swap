#!/bin/bash

echo "Add NSG rules to allow SSH from GitHub runner"

vmIpV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'ipAddress')" | sed "s/\r//")
vmIpV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")

echo "Create NSG rule for GitHub runner inbound access to VNet"
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

echo "Create NSG rule for GitHub runner inbound access to VM v2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-GitHub-VMv2" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="$NSG_RULE_NAME_GH_SOURCE_VM_V2" \
	priority=$NSG_RULE_PRIORITY_GH_SOURCE_VM_V2 \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="$vmIpV2" \
	destinationPortRange="22"

echo "Create NSG rule for GitHub runner inbound access to VM v3"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-GitHub-VMv3" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="$NSG_RULE_NAME_GH_SOURCE_VM_V3" \
	priority=$NSG_RULE_PRIORITY_GH_SOURCE_VM_V3 \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="$vmIpV3" \
	destinationPortRange="22"