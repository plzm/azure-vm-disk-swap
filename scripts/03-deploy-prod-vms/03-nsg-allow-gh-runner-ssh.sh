#!/bin/bash

echo "Add NSG rules to allow SSH from GitHub runner"

vmIp1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")
vmIp2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

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

echo "Create NSG rule for GitHub runner inbound access to Prod VM1"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-GitHub-VM1" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="$NSG_RULE_NAME_GH_PROD_VM_1" \
	priority=$NSG_RULE_PRIORITY_GH_PROD_VM_1 \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="$vmIp1" \
	destinationPortRange="22"

echo "Create NSG rule for GitHub runner inbound access to Prod VM2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-GitHub-VM1" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="$NSG_RULE_NAME_GH_PROD_VM_2" \
	priority=$NSG_RULE_PRIORITY_GH_PROD_VM_2 \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="$vmIp2" \
	destinationPortRange="22"
