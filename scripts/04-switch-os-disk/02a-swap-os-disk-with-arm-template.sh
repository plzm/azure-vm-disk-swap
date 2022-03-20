#!/bin/bash

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')" | sed "s/\r//")
fi

echo "Retrieve Admin Username and SSH Public Key from Key Vault"
vmAdminUsername=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME" -o tsv --query 'value')" | sed "s/\r//")
vmAdminUserSshPublicKey=$(echo "$(az keyvault secret show --subscription "$SUBSCRIPTION_ID" --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY" -o tsv --query 'value')" | sed "s/\r//")


echo "Get the resource IDs of the OS disks"
vm1OsDiskIdV1=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V1" -o tsv --query "id")" | sed "s/\r//")
vm1OsDiskIdV2=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
vm1OsDiskIdV3=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_1_OS_DISK_NAME_V3" -o tsv --query "id")" | sed "s/\r//")

vm2OsDiskIdV1=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_2_OS_DISK_NAME_V1" -o tsv --query "id")" | sed "s/\r//")
vm2OsDiskIdV2=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_2_OS_DISK_NAME_V2" -o tsv --query "id")" | sed "s/\r//")
vm2OsDiskIdV3=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_2_OS_DISK_NAME_V3" -o tsv --query "id")" | sed "s/\r//")



echo "TODO TODO TODO how to set this in a pipeline"
echo "Set the resource IDs of the OS disks to swap TO"
newVmOsDiskIdVm1=$vm1OsDiskIdV2
newVmOsDiskIdVm2=$vm2OsDiskIdV2



echo "Deallocate the existing VMs so we can swap in different OS disks"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_1" --verbose
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" --name "$VM_NAME_2" --verbose

echo "Update VM 1"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$VM_NAME_1""-OS-DISK" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_NAME_1" \
	virtualMachineSize="$VM_SIZE" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskId="$newVmOsDiskIdVm1" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_DEPLOY" \
	networkInterfaceName="$VM_NAME_1"

echo "Update VM 2"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$VM_NAME_2""-OS-DISK" --verbose \
	-g "$RG_NAME_DEPLOY" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_NAME_2" \
	virtualMachineSize="$VM_SIZE" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskId="$newVmOsDiskIdVm2" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_DEPLOY" \
	networkInterfaceName="$VM_NAME_2"

echo "Start the VMs"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_NAME_1" --verbose
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_DEPLOY" -n "$VM_NAME_2" --verbose
