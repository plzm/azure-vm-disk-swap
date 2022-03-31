#!/bin/bash
set -eu

keyFilePath=~/.ssh/"$DEPLOYMENT_SSH_USER_KEY_NAME".pub
vmDeploySshPublicKey=$(<$keyFilePath)

echo "Public IP - Prod VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-PIP-vNext" --verbose \
	-g "$RG_NAME_VM_SOURCE" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_SRC_NAME_VNEXT" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_SRC_NAME_VNEXT"

echo "Network Interface - Prod VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-NIC-vNext" --verbose \
	-g "$RG_NAME_VM_SOURCE" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_SRC_NAME_VNEXT" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_VM_SOURCE" \
	publicIpName="$VM_SRC_NAME_VNEXT" \
	ipConfigName="$IP_CONFIG_NAME"

echo "VM - Prod VM"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM-vNext" --verbose \
	-g "$RG_NAME_VM_SOURCE" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	virtualMachineName="$VM_SRC_NAME_VNEXT" \
	virtualMachineSize="$VM_SIZE" \
	imageResourceId="" \
	publisher="$OS_PUBLISHER_VNEXT" \
	offer="$OS_OFFER_VNEXT" \
	sku="$OS_SKU_VNEXT" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$DEPLOYMENT_SSH_USER_NAME" \
	adminSshPublicKey="$vmDeploySshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskStorageType="$OS_DISK_STORAGE_TYPE" \
	osDiskSizeInGB="$OS_DISK_SIZE_IN_GB" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_VM_SOURCE" \
	networkInterfaceName="$VM_SRC_NAME_VNEXT"
