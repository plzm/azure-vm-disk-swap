#!/bin/bash
set -eux

# If a Managed Identity Name was provided, get its Resource ID
if [ ! -z $USERNAME_UAMI ]
then
	uamiResourceId=$(echo "$(az identity show --subscription ""$SUBSCRIPTION_ID"" -g ""$RG_NAME_SECURITY"" --name ""$USERNAME_UAMI"" -o tsv --query 'id')" | sed "s/\r//")
fi

echo "Get the resource IDs of vNow and vNext OS disks"
vm1OsDiskIdVNow=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" -n "$VM_1_OS_DISK_NAME_VNOW" -o tsv --query "id")" | sed "s/\r//")
vm1OsDiskIdVNext=$(echo "$(az disk show --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" -n "$VM_1_OS_DISK_NAME_VNEXT" -o tsv --query "id")" | sed "s/\r//")

echo "TODO TODO TODO how to set this in a pipeline"
echo "Set the resource IDs of the OS disks to swap TO"
newVmOsDiskIdVm1=$vm1OsDiskIdVNext

echo "Deallocate VM so we can swap OS disk"
az vm deallocate --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" --name "$VM_PROD_NAME_1" --verbose

echo "Update VM 1"
az deployment group create --subscription "$SUBSCRIPTION_ID" -n "$VM_PROD_NAME_1""-OS-DISK" --verbose \
	-g "$RG_NAME_VM_PROD" --template-uri "$TEMPLATE_VM" \
	--parameters \
	location="$LOCATION" \
	userAssignedManagedIdentityResourceId="$uamiResourceId" \
	virtualMachineName="$VM_PROD_NAME_1" \
	virtualMachineSize="$VM_SIZE" \
	version="$VM_VERSION" \
	provisionVmAgent="$PROVISION_VM_AGENT" \
	adminUsername="$VM_ADMIN_SSH_USER_NAME" \
	adminSshPublicKey="$VM_ADMIN_SSH_PUBLIC_KEY" \
	virtualMachineTimeZone="$VM_TIME_ZONE" \
	osDiskId="$newVmOsDiskIdVm1" \
	dataDiskStorageType="$DATA_DISK_STORAGE_TYPE" \
	dataDiskCount="$DATA_DISK_COUNT" \
	dataDiskSizeInGB="$DATA_DISK_SIZE_IN_GB" \
	vmAutoShutdownTime="$VM_AUTO_SHUTDOWN_TIME" \
	enableAutoShutdownNotification="$VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" \
	autoShutdownNotificationWebhookURL="$VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" \
	autoShutdownNotificationMinutesBefore="$VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" \
	resourceGroupNameNetworkInterface="$RG_NAME_VM_PROD" \
	networkInterfaceName="$VM_PROD_NAME_1"

echo "Start VM"
az vm start --subscription "$SUBSCRIPTION_ID" -g "$RG_NAME_VM_PROD" -n "$VM_PROD_NAME_1" --verbose
