#!/bin/bash

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')" | sed "s/\r//")
fi

echo "Deploy Prod VM1 Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM1-PIP" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_PROD_NAME_1" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_PROD_NAME_1"

echo "Deploy Prod VM1 Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM1-NIC" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_PROD_NAME_1" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_DEPLOY" \
	publicIpName="$VM_PROD_NAME_1" \
	ipConfigName="$IP_CONFIG_NAME"

echo "Deploy Prod VM1 with initial OS"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM1" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_PROD_NAME_1" \
	virtualMachineSize="$VM_SIZE" \
	publisher="$OS_PUBLISHER_1" \
	offer="$OS_OFFER_1" \
	sku="$OS_SKU_1" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$VM_ADMIN_SSH_USER_NAME" \
	adminSshPublicKey="$VM_ADMIN_SSH_PUBLIC_KEY" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskName="$VM_1_OS_DISK_NAME_V1" \
	osDiskStorageType="$OS_DISK_STORAGE_TYPE" \
	osDiskSizeInGB="$OS_DISK_SIZE_IN_GB" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_DEPLOY" \
	networkInterfaceName="$VM_PROD_NAME_1"


echo "Deploy Prod VM2 Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM2-PIP" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_PROD_NAME_2" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_PROD_NAME_2"

echo "Deploy Prod VM2 Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM2-NIC" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_PROD_NAME_2" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_DEPLOY" \
	publicIpName="$VM_PROD_NAME_2" \
	ipConfigName="$IP_CONFIG_NAME"

echo "Deploy Prod VM2 with initial OS"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "Prod-VM2" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_PROD_NAME_2" \
	virtualMachineSize="$VM_SIZE" \
	publisher="$OS_PUBLISHER_1" \
	offer="$OS_OFFER_1" \
	sku="$OS_SKU_1" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$VM_ADMIN_SSH_USER_NAME" \
	adminSshPublicKey="$VM_ADMIN_SSH_PUBLIC_KEY" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskName="$VM_2_OS_DISK_NAME_V1" \
	osDiskStorageType="$OS_DISK_STORAGE_TYPE" \
	osDiskSizeInGB="$OS_DISK_SIZE_IN_GB" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_DEPLOY" \
	networkInterfaceName="$VM_PROD_NAME_2"

echo "Production VMs deployed"


echo "Deallocate Production VMs"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_1" --verbose
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_PROD_NAME_2" --verbose
