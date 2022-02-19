#!/bin/bash

echo "Create NSG"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-""$LOCATION" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG" \
	--parameters \
	location="$LOCATION" \
	nsgName="$NSG_NAME" \
	nsgRuleInbound100Src="$NSG_RULE_INBOUND_100_SRC"

echo "Create VNet"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VNet-""$LOCATION" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_VNET" \
	--parameters \
	location="$LOCATION" \
	vnetName="$VNET_NAME" \
	vnetPrefix="$VNET_PREFIX" \
	enableDdosProtection="$VNET_ENABLE_DDOS_PROTECTION" \
	enableVmProtection="$VNET_ENABLE_VM_PROTECTION"

echo "Create Subnet"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VNet-Subnet-""$LOCATION" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_SUBNET" \
	--parameters \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	subnetPrefix="$SUBNET_PREFIX" \
	nsgResourceGroup="$RG_NAME_NET" \
	nsgName="$NSG_NAME" \
	serviceEndpoints="$SUBNET_SERVICE_ENDPOINTS" \
	privateEndpointNetworkPolicies="$SUBNET_PRIVATE_ENDPOINT_NETWORK_POLICIES" \
	privateLinkServiceNetworkPolicies="$SUBNET_PRIVATE_LINK_NETWORK_POLICIES"

