#!/bin/bash

echo "Create NSG Source"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$NSG_NAME_SOURCE" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG" \
	--parameters \
	location="$LOCATION" \
	nsgName="$NSG_NAME_SOURCE"

echo "Create NSG Prod"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$NSG_NAME_PROD" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG" \
	--parameters \
	location="$LOCATION" \
	nsgName="$NSG_NAME_PROD"

echo "Create NSG Source rule for Dev inbound access"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Source-Rule-100" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME_SOURCE" \
	nsgRuleName="$NSG_RULE_NAME_DEV" \
	priority=$NSG_RULE_PRIORITY_DEV \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="$NSG_RULE_SRC_ADDRESS_DEV" \
	sourcePortRange="*" \
	destinationAddressPrefix="*" \
	destinationPortRange="*"

echo "Create NSG Prod rule for Dev inbound access"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Prod-Rule-100" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME_PROD" \
	nsgRuleName="$NSG_RULE_NAME_DEV" \
	priority=$NSG_RULE_PRIORITY_DEV \
	direction="Inbound" \
	access="Allow" \
	protocol="*" \
	sourceAddressPrefix="$NSG_RULE_SRC_ADDRESS_DEV" \
	sourcePortRange="*" \
	destinationAddressPrefix="*" \
	destinationPortRange="*"

echo "Create VNet"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VNet-""$LOCATION" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_VNET" \
	--parameters \
	location="$LOCATION" \
	vnetName="$VNET_NAME" \
	vnetPrefix="$VNET_PREFIX" \
	enableDdosProtection="$VNET_ENABLE_DDOS_PROTECTION" \
	enableVmProtection="$VNET_ENABLE_VM_PROTECTION"

echo "Create Subnet Source"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$SUBNET_NAME_SOURCE" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_SUBNET" \
	--parameters \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME_SOURCE" \
	subnetPrefix="$SUBNET_PREFIX_SOURCE" \
	nsgResourceGroup="$RG_NAME_NET" \
	nsgName="$NSG_NAME_SOURCE" \
	serviceEndpoints="$SUBNET_SERVICE_ENDPOINTS" \
	privateEndpointNetworkPolicies="$SUBNET_PRIVATE_ENDPOINT_NETWORK_POLICIES" \
	privateLinkServiceNetworkPolicies="$SUBNET_PRIVATE_LINK_NETWORK_POLICIES"

echo "Create Subnet Prod"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$SUBNET_NAME_PROD" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_SUBNET" \
	--parameters \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME_PROD" \
	subnetPrefix="$SUBNET_PREFIX_PROD" \
	nsgResourceGroup="$RG_NAME_NET" \
	nsgName="$NSG_NAME_PROD" \
	serviceEndpoints="$SUBNET_SERVICE_ENDPOINTS" \
	privateEndpointNetworkPolicies="$SUBNET_PRIVATE_ENDPOINT_NETWORK_POLICIES" \
	privateLinkServiceNetworkPolicies="$SUBNET_PRIVATE_LINK_NETWORK_POLICIES"
