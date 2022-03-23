#!/bin/bash

echo "Add NSG rule to allow SSH from GitHub runner to VM"
echo "Usage: ./06-nsg-allow-gh-runner-ssh-vm.sh \$vmResourceGroupName \$vmName \$nsgRuleName \$nsgRulePriority"

vmResourceGroupName=$1
vmName=$2
nsgRuleName=$3
nsgRulePriority=$4

vmIp=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$vmResourceGroupName"" -n ""$vmName"" -o tsv --query 'ipAddress')" | sed "s/\r//")

echo "Create NSG rule for GitHub runner inbound access to VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-GitHub-VM" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="$nsgRuleName" \
	priority=$nsgRulePriority \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="AzureCloud" \
	sourcePortRange="*" \
	destinationAddressPrefix="$vmIp" \
	destinationPortRange="22"
