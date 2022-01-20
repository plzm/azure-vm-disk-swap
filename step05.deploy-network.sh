#!/bin/bash

. ./step00.variables.sh

echo "Create NSG"
az deployment group create --subscription "$subscriptionId" -n "NSG-""$location" --verbose \
	-g "$rgNameNet" --template-uri "$templateNsg" \
	--parameters \
	location="$location" \
	nsgName="$nsgName" \
	nsgRuleInbound100Src="$nsgRuleInbound100Src"

echo "Create VNet"
az deployment group create --subscription "$subscriptionId" -n "VNet-""$location" --verbose \
	-g "$rgNameNet" --template-uri "$templateVnet" \
	--parameters \
	location="$location" \
	vnetName="$vnetName" \
	vnetPrefix="$vnetPrefix" \
	enableDdosProtection="false" \
	enableVmProtection="false"

echo "Create Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Subnet-""$location" --verbose \
	-g "$rgNameNet" --template-uri "$templateSubnet" \
	--parameters \
	vnetName="$vnetName" \
	subnetName="$subnetName" \
	subnetPrefix="$subnetPrefix" \
	nsgResourceGroup="$rgNameNet" \
	nsgName="$nsgName" \
	serviceEndpoints="" \
	privateEndpointNetworkPolicies="Enabled" \
	privateLinkServiceNetworkPolicies="Enabled"

