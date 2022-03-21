#!/bin/bash

echo "Remove NSG rules to allow SSH from GitHub runner"

vmIpV2=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V2"" -o tsv --query 'ipAddress')" | sed "s/\r//")
vmIpV3=$(echo "$(az network public-ip show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SOURCE"" -n ""$VM_SRC_NAME_V3"" -o tsv --query 'ipAddress')" | sed "s/\r//")

echo "Remove NSG rule for GitHub runner inbound access to VNet"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME_GH_VNET"

echo "Remove NSG rule for GitHub runner inbound access to VM v2"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME_GH_SOURCE_VM_V2"

echo "Remove NSG rule for GitHub runner inbound access to VM v3"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME_GH_SOURCE_VM_V3"
