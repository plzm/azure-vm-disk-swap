#!/bin/bash

echo "Deploy Destination VM to use for OS disk swaps"

echo "Deploy Public IP"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM3-PIP-""$LOCATION" --verbose \
	-g "$RG_NAME_DEPLOY" --template-file "$TEMPLATE_PUBLIC_IP" \
	--parameters \
	location="$LOCATION" \
	publicIpName="$VM3_PIP_NAME" \
	publicIpType="$VM_PUBLIC_IP_TYPE" \
	publicIpSku="$VM_PUBLIC_IP_SKU" \
	domainNameLabel="$VM3_NAME"

echo "Deploy Network Interface"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM3-NIC-""$LOCATION" --verbose \
	-g "$RG_NAME_DEPLOY" --template-file "$TEMPLATE_NIC" \
	--parameters \
	location="$LOCATION" \
	networkInterfaceName="$VM3_NIC_NAME" \
	vnetResourceGroup="$RG_NAME_NET" \
	vnetName="$VNET_NAME" \
	subnetName="$SUBNET_NAME" \
	enableAcceleratedNetworking="$VM_ENABLE_ACCELERATED_NETWORKING" \
	privateIpAllocationMethod="$PRIVATE_IP_ALLOCATION_METHOD" \
	publicIpResourceGroup="$RG_NAME_DEPLOY" \
	publicIpName="$VM3_PIP_NAME" \
	ipConfigName="$IP_CONFIG_NAME"

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId="$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')"
fi

echo "Retrieve Admin Username and SSH Public Key from Key Vault"
# Note, while we defined these in step00, THAT was just to put them INTO Key Vault in step04.
vmAdminUsername="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_ADMIN_USERNAME" -o tsv --query 'value')"
vmAdminUserSshPublicKey="$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')"

echo "Deploy VM ARM Template"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "VM3-""$LOCATION" --verbose \
	-g "$RG_NAME_DEPLOY" --template-file "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM3_NAME" \
	virtualMachineSize="$VM_SIZE" \
	publisher="$OS_PUBLISHER" \
	offer="$OS_OFFER" \
	sku="$OS_SKU_3" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskName="$VM3_OS_DISK_NAME_1" \
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
	networkInterfaceName="$VM3_NIC_NAME"

echo "Destination VM deployed"
