#!/bin/bash

# ##################################################
# NOTE - in non-GitHub environment, to work with the env vars exported herein from other files, remember to dot-source this file at the prompt!
# . ./env-vars.sh
# ##################################################

setEnvVar() {
	# Set an env var's value at runtime with dynamic variable name
	# If in GitHub Actions runner, will export env var both to Actions and local shell
  # Usage:
  # setEnvVar "variableName" "variableValue"

  varName=$1
  varValue=$2

	if [[ ! -z $GITHUB_ACTIONS ]]
	then
		# We are in GitHub CI environment - export to GitHub Actions workflow context for availability in later tasks in this workflow
		cmd=$(echo -e "echo \x22""$varName""=""$varValue""\x22 \x3E\x3E \x24GITHUB_ENV")
		eval $cmd
	fi

	# Export for local/immediate use, whether on GHA runner or shell/wherever
	cmd="export ""$varName""=\"""$varValue""\""
	eval $cmd
}

# ##################################################
# Variables only for this file - not exported to env vars but used to construct some of them
# Consider moving these to repo secrets or a config/secret store somewhere...

azureLocation="eastus2"
subscriptionName="Sandbox"

myLocalIpAddress="75.68.47.183" # Make this blank if you don't want an NSG rule created that allows inbound traffic from this IP address

# Change this as desired. Suggest making it indicative of the VM OS publisher configured below.
osInfix="u"

resourceNamingInfix="pz"

# ARM Templates
# Use files elsewhere with az deployment group create --template-uri
templateRootUri="https://raw.githubusercontent.com/plzm/azure-deploy/main/template/"
# Use this to choose local or remote templates
templateRoot=$templateRootUri # We will use remote template files via --template-uri

# Suffixes for VM versions - we'll deploy with vNow and prepare image for vNext. vNow and vNext will be swappable.
# This simulates starting with a deployed VM and wanting to swap between its initial OS disk and a new disk created from image.
# Here we just use suffixes for months - current and next month. You can swap in your own versioning scheme.
suffixVNow=$(date +"%Y%m")
suffixVNext=$(date -d "+1 month" +"%Y%m")

# VM Admin user SSH public key - we assume we are provided ONLY a public key, not the private key, and that it is generated and managed outside this context.
# We use this to enable a deployed VM to be logged into and used by the user account whose public SSH key this is.
# This SSH key is not used in this context to log into the VM. It's added to the VM for eventual use by this user account.
# It's hard-coded here but of course if this is stored in the Key Vault used elsewhere here, you can just retrieve it from there at this point.
vmAdminSshUserName="vmadmin"
vmAdminSshKeyName="id_""$vmAdminSshUserName"
vmAdminSshPublicKeyPrefix="ssh-rsa"
vmAdminSshPublicKeyInfix="AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw=="
vmAdminSshPublicKey="$vmAdminSshPublicKeyPrefix"" ""$vmAdminSshPublicKeyInfix"" ""$vmAdminSshUserName"

deploySshUserName="deploy"
deploySshKeyName="id_""$deploySshUserName"
# ##################################################

# ##################################################
# SSH Key Pair for Deployment

# Deployment username - used only to deploy/configure VM
setEnvVar "DEPLOYMENT_SSH_USER_NAME" "$deploySshUserName"
setEnvVar "DEPLOYMENT_SSH_USER_KEY_NAME" "$deploySshKeyName"
setEnvVar "DEPLOYMENT_SSH_KEY_TYPE" "rsa"
setEnvVar "DEPLOYMENT_SSH_KEY_BITS" 4096
setEnvVar "DEPLOYMENT_SSH_KEY_PASSPHRASE" "" # Use blank for convenience here as deployment SSH key will be short-lived
# DEPLOYMENT_SSH_PUBLIC_KEY # Placeholder - not set here
# DEPLOYMENT_SSH_PRIVATE_KEY # Placeholder - not set here

# VM Admin username - what a VM user would use eventually to work with a VM
setEnvVar "VM_ADMIN_SSH_USER_NAME" "$vmAdminSshUserName"
setEnvVar "VM_ADMIN_SSH_USER_KEY_NAME" "$vmAdminSshKeyName"
setEnvVar "VM_ADMIN_SSH_PUBLIC_KEY_INFIX" "$vmAdminSshPublicKeyInfix"
setEnvVar "VM_ADMIN_SSH_PUBLIC_KEY" "$vmAdminSshPublicKey"

# ##################################################

# ##################################################
# Variables to export to env vars

setEnvVar "VM_SUFFIX_VNOW" "$suffixVNow"
setEnvVar "VM_SUFFIX_VNEXT" "$suffixVNext"

setEnvVar "NSG_RULE_SRC_ADDRESS_DEV" "$myLocalIpAddress"
setEnvVar "NSG_RULE_NAME_DEV" "Dev-Inbound"
setEnvVar "NSG_RULE_PRIORITY_DEV" 100
setEnvVar "NSG_RULE_NAME_GH_VNET" "GitHub-Runner-SSH-Inbound-VNet"
setEnvVar "NSG_RULE_PRIORITY_GH_VNET" 101

# Subscription ID. bash/az cli started appending line feed so here we get rid of it.
subscriptionId=$(echo "$(az account show -s $subscriptionName -o tsv --query 'id')" | sed "s/\r//")
setEnvVar "SUBSCRIPTION_ID" "$subscriptionId"

# Get Tenant ID for Subscription. Need this to create User-Assigned Managed Identity and Key Vault.
tenantId=$(echo "$(az account show -s $subscriptionName -o tsv --query 'tenantId')" | sed "s/\r//")
setEnvVar "TENANT_ID" "$tenantId"

# Deployment
setEnvVar "LOCATION" "eastus2"

# Resource Groups
setEnvVar "RG_NAME_SECURITY" "$resourceNamingInfix""-security-""$azureLocation"
setEnvVar "RG_NAME_GALLERY" "$resourceNamingInfix""-gallery-""$azureLocation"
setEnvVar "RG_NAME_NET" "$resourceNamingInfix""-net-""$azureLocation"
setEnvVar "RG_NAME_VM_SOURCE" "$resourceNamingInfix""-vm-source-""$azureLocation"
setEnvVar "RG_NAME_VM_PROD" "$resourceNamingInfix""-vm-prod-""$azureLocation"

# User-Assigned Managed Identity
setEnvVar "USERNAME_UAMI" "$resourceNamingInfix""-vm-uami-""$azureLocation"

# Network
setEnvVar "NSG_NAME_SOURCE" "nsg-source-""$azureLocation"
setEnvVar "NSG_NAME_PROD" "nsg-prod-""$azureLocation"

setEnvVar "VNET_NAME" "vm-vnet-""$azureLocation"
setEnvVar "VNET_PREFIX" "10.4.0.0/16"
setEnvVar "VNET_ENABLE_DDOS_PROTECTION" "Disabled" # Enabled or Disabled
setEnvVar "VNET_ENABLE_VM_PROTECTION" "Disabled" # Enabled or Disabled

setEnvVar "SUBNET_NAME_SOURCE" "source"
setEnvVar "SUBNET_PREFIX_SOURCE" "10.4.1.0/24"

setEnvVar "SUBNET_NAME_PROD" "prod"
setEnvVar "SUBNET_PREFIX_PROD" "10.4.254.0/24"

setEnvVar "SUBNET_SERVICE_ENDPOINTS" ""
setEnvVar "SUBNET_PRIVATE_ENDPOINT_NETWORK_POLICIES" "Enabled" # Enabled or Disabled
setEnvVar "SUBNET_PRIVATE_LINK_NETWORK_POLICIES" "Enabled" # Enabled or Disabled

# Now assemble all the individual template paths
# ARM Templates
setEnvVar "TEMPLATE_UAMI" "$templateRoot""identity.user-assigned-mi.json"
setEnvVar "TEMPLATE_NSG" "$templateRoot""net.nsg.json"
setEnvVar "TEMPLATE_NSG_RULE" "$templateRoot""net.nsg.rule.json"
setEnvVar "TEMPLATE_VNET" "$templateRoot""net.vnet.json"
setEnvVar "TEMPLATE_SUBNET" "$templateRoot""net.vnet.subnet.json"
setEnvVar "TEMPLATE_COMPUTE_GALLERY" "$templateRoot""compute.gallery.json"
setEnvVar "TEMPLATE_PUBLIC_IP" "$templateRoot""net.public-ip.json"
setEnvVar "TEMPLATE_NIC" "$templateRoot""net.network-interface.json"
setEnvVar "TEMPLATE_VM" "$templateRoot""vm.linux.json"
setEnvVar "TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT" "$templateRoot""vm.extension.custom-script.json"

# ##################################################

# VM
setEnvVar "HYPER_V_GENERATION" "V1"
setEnvVar "OS_STATE" "Generalized"

# ##################################################
# Two VM OS blocks are provided: Ubuntu or RedHat. Or you can roll your own.
# I swap OSes here to also show how to vary OS offer and SKU. Totally optional, feel free to stick with your one happy OS across many image versions.
# ##################################################
# az vm image list-skus -l $LOCATION --publisher RedHat --offer RHEL -o tsv --query '[].name'
# ##################################################
setEnvVar "OS_PUBLISHER_VNOW" "Canonical"
setEnvVar "OS_OFFER_VNOW" "0001-com-ubuntu-server-focal"
setEnvVar "OS_SKU_VNOW" "20_04-lts"

setEnvVar "OS_PUBLISHER_VNEXT" "Canonical"
setEnvVar "OS_OFFER_VNEXT" "0001-com-ubuntu-server-impish"
setEnvVar "OS_SKU_VNEXT" "21_10"
# ##################################################
# setEnvVar "OS_PUBLISHER_VNOW" "RedHat"
# setEnvVar "OS_OFFER_VNOW" "RHEL"
# setEnvVar "OS_SKU_VNOW" "8_3"

# setEnvVar "OS_PUBLISHER_VNEXT" "RedHat"
# setEnvVar "OS_OFFER_VNEXT" "RHEL"
# setEnvVar "OS_SKU_VNEXT" "8_4"
# ##################################################

setEnvVar "VM_VERSION" "latest"

setEnvVar "VM_ENABLE_ACCELERATED_NETWORKING" "true" # This is not supported for all VM Sizes - check your VM Size!
setEnvVar "PROVISION_VM_AGENT" "true"
setEnvVar "VM_SIZE" "Standard_D4s_v3"

setEnvVar "VM_PUBLIC_IP_TYPE" "Static" # Static or Dynamic - Standard SKU requires Static
setEnvVar "VM_PUBLIC_IP_SKU" "Standard" # Basic or Standard

setEnvVar "PRIVATE_IP_ALLOCATION_METHOD" "Dynamic"
setEnvVar "IP_CONFIG_NAME" "ipConfig1"

setEnvVar "VM_TIME_ZONE" "Eastern Standard Time"

setEnvVar "OS_DISK_STORAGE_TYPE" "Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
setEnvVar "OS_DISK_SIZE_IN_GB" 64
setEnvVar "DATA_DISK_STORAGE_TYPE" "Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
setEnvVar "DATA_DISK_COUNT" 0
setEnvVar "DATA_DISK_SIZE_IN_GB" 1023
setEnvVar "VM_AUTO_SHUTDOWN_TIME" "1800"
setEnvVar "VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION" "Disabled" # Disabled | Enabled
setEnvVar "VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL" "" # Provide if set enableAutoShutdownNotification "Enabled"
setEnvVar "VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE" 15

# Image source VM
setEnvVar "VM_SRC_NAME_VNEXT" "$resourceNamingInfix""-""$osInfix""-""$VM_SUFFIX_VNEXT"

# Azure Compute Gallery (used to be called Shared Image Gallery but let's-rename-things-gremlins visited)
setEnvVar "GALLERY_NAME" "$resourceNamingInfix""_gallery_""$azureLocation"
setEnvVar "VM_OS_TYPE" "Linux" # Linux | Windows
setEnvVar "VM_IMG_DEF_NAME_VNEXT" "custom-""$osInfix""-""$OS_PUBLISHER_VNEXT""-""$OS_OFFER_VNEXT""-""$OS_SKU_VNEXT""-""$VM_SUFFIX_VNEXT"
setEnvVar "VM_IMG_DEF_VERSION_VNEXT" "1.0.0" # Could make this dynamic if, for example, generating more than one image version per image definition.
setEnvVar "VM_IMG_NAME_VNEXT" "$VM_SRC_NAME_VNEXT""-image"

# Production VM
setEnvVar "VM_PROD_NAME_1" "$resourceNamingInfix""-""$osInfix""-1"
# ##################################################
