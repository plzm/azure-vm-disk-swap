#!/bin/bash

echo "Create NSG"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-""$LOCATION" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG" \
	--parameters \
	location="$LOCATION" \
	nsgName="$NSG_NAME"

echo "Create NSG rule for Dev inbound access"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "NSG-Rule-100" --verbose \
	-g "$RG_NAME_NET" --template-uri "$TEMPLATE_NSG_RULE" \
	--parameters \
	nsgName="$NSG_NAME" \
	nsgRuleName="Dev-Inbound" \
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

