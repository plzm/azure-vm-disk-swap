#!/bin/bash

echo "Add NSG rules to allow SSH from GitHub runner"

vmIpV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'ipAddress')" | sed "s/\r//")
vmIpV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")

echo "Create NSG rule for GitHub runner inbound access to VM2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-111" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="GitHub-Runner-SSH-Inbound-VM2" \
	priority=111 \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="$vmIpV2" \
	destinationPortRange="22"

echo "Create NSG rule for GitHub runner inbound access to VM3"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-112" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="GitHub-Runner-SSH-Inbound-VM3" \
	priority=112 \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="$vmIpV3" \
	destinationPortRange="22"
