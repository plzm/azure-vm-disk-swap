#!/bin/bash
set -eux

echo "Remove NSG rules to allow SSH from GitHub runner"

vmIp1=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_1"" -o tsv --query 'ipAddress')" | sed "s/\r//")
vmIp2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_VM_PROD"" -n ""$VM_PROD_NAME_2"" -o tsv --query 'ipAddress')" | sed "s/\r//")

echo "Remove NSG rule for GitHub runner inbound access to VNet"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME_GH_VNET"

echo "Remove NSG rule for GitHub runner inbound access to Prod VM 1"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME_GH_PROD_VM_1"

echo "Remove NSG rule for GitHub runner inbound access to Prod VM 2"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME_GH_PROD_VM_2"
