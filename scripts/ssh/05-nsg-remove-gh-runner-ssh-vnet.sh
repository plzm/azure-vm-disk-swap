#!/bin/bash

echo "Remove NSG rule to allow SSH from GitHub runner to VNet"
az network nsg rule delete --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_NET" --verbose \
	--nsg-name "$NSG_NAME" --name "$NSG_RULE_NAME_GH_VNET"
