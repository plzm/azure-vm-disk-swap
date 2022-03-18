#!/bin/bash

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')" | sed "s/\r//")
fi

echo "Retrieve VM Admin Username and SSH Public Key from Key Vault - this is NOT the deploy user, this is the actual VM admin, for production VM deployment with a functional OS and not to just generalize to an image"
vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")

echo "Deploy VM 1"
echo "Deploy Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM1-PIP" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_NAME_1" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_NAME_1"

echo "Deploy Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM1-NIC" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_NAME_1" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_DEPLOY" \
	publicIpName="$VM_NAME_1" \
	ipConfigName="$IP_CONFIG_NAME"

echo "Deploy VM with initial OS"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM1" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_NAME_1" \
	virtualMachineSize="$VM_SIZE" \
	publisher="$OS_PUBLISHER_1" \
	offer="$OS_OFFER_1" \
	sku="$OS_SKU_1" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminSshPublicKey" \
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
	networkInterfaceName="$VM_NAME_1"

echo "Deploy VM 2"
echo "Deploy Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM2-PIP" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM_NAME_2" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM_NAME_2"

echo "Deploy Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM2-NIC" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM_NAME_2" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_DEPLOY" \
	publicIpName="$VM_NAME_2" \
	ipConfigName="$IP_CONFIG_NAME"

echo "Deploy VM with initial OS"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM2" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_NAME_2" \
	virtualMachineSize="$VM_SIZE" \
	publisher="$OS_PUBLISHER_1" \
	offer="$OS_OFFER_1" \
	sku="$OS_SKU_1" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminSshPublicKey" \
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
	networkInterfaceName="$VM_NAME_2"

echo "Destination VMs deployed"


echo "Deallocate Destination VMs"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_1" --verbose --no-wait
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_2" --verbose --no-wait
