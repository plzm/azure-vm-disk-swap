#!/bin/bash

# NOTE - to work with the env vars exported herein from other files, remember to dot-source this file at the prompt!
# . ./01-set-env-vars.sh

# ##################################################
# Variables only for this file - not exported to env vars

subscriptionName="Sandbox"

# Change this as desired. Suggest making it indicative of the VM OS publisher configured below.
osInfix="u"

resourceNamingInfix="pz"

# ARM Templates
# Use local files with az deployment group create --template-file
templateRootLocal="../../template/"
# Use files elsewhere with az deployment group create --template-uri
templateRootUri="https://raw.githubusercontent.com/plzm/azure-deploy/main/template/"
# Use this to choose local or remote templates
templateRoot=$templateRootUri # We will use remote template files via --template-uri

# Suffixes for three VM versions - we'll deploy with 1 and prepare images for 2 and 3. Then all three will be swappable.
# This simulates starting with a deployed VM and wanting to swap between its initial OS disk and additional disks created from images.
# Here we just use suffixes for months - current, then next month, then next month after that. You can swap in your own versioning scheme.
suffixVersion1=$(date +"%Y%m")
suffixVersion2=$(date -d "+1 month" +"%Y%m")
suffixVersion3=$(date -d "+2 months" +"%Y%m")

# ##################################################

# ##################################################
# SSH Key Pair for Deployment

# Deployment username - used only to deploy/configure VM
export DEPLOYMENT_SSH_USER_NAME="deploy"
export DEPLOYMENT_SSH_USER_KEY_NAME="id_""$DEPLOYMENT_SSH_USER_NAME"
export DEPLOYMENT_SSH_KEY_TYPE="rsa"
export DEPLOYMENT_SSH_KEY_BITS=4096
export DEPLOYMENT_SSH_KEY_PASSPHRASE="" # Use blank for convenience here as deployment SSH key will be short-lived
# DEPLOYMENT_SSH_PUBLIC_KEY # Placeholder - not set here
# DEPLOYMENT_SSH_PRIVATE_KEY # Placeholder - not set here

# VM Admin username - what a VM user would use eventually to work with a VM
export VM_ADMIN_SSH_USER_NAME="pelazem"
export VM_ADMIN_SSH_USER_KEY_NAME="id_rsa"
# VM Admin user SSH public key - we assume we are provided ONLY a public key, not the private key, and that it is generated and managed outside this context.
# We use this to enable a deployed VM to be logged into and used by the user account whose public SSH key this is.
# This SSH key is not used in this context to log into the VM. It's added to the VM for eventual use by this user account.
# It's hard-coded here but of course if this is stored in the Key Vault used elsewhere here, you can just retrieve it from there at this point.
vmAdminSshPublicKeyInfix="AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw=="
export VM_ADMIN_SSH_PUBLIC_KEY="ssh-rsa ""$vmAdminSshPublicKeyInfix"" ""$VM_ADMIN_SSH_USER_NAME"


# Key Vault Secret NAMES of the secrets whose actual VALUES you write to or retrieve from Key Vault
export KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_USER_NAME="vm-deploy-ssh-user-name"
export KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PUBLIC_KEY="vm-deploy-ssh-public-key"
export KEYVAULT_SECRET_NAME_DEPLOYMENT_SSH_PRIVATE_KEY="vm-deploy-ssh-private-key"
export KEYVAULT_SECRET_NAME_VM_ADMIN_USER_NAME="vm-admin-ssh-user-name"
export KEYVAULT_SECRET_NAME_VM_ADMIN_SSH_PUBLIC_KEY="vm-admin-ssh-public-key"

# ##################################################

# ##################################################
# Variables to export to env vars

# Provide at least these values
export NSG_RULE_INBOUND_100_SRC="75.68.47.183" # Leave empty to not add an inbound NSG rule for dev/test - see the net.nsg template

# Subscription ID. bash/az cli started appending line feed so here we get rid of it.
export SUBSCRIPTION_ID=$(echo "$(az account show -s $subscriptionName -o tsv --query 'id')" | sed "s/\r//")

# Get Tenant ID for Subscription. Need this to create User-Assigned Managed Identity and Key Vault.
export TENANT_ID=$(echo "$(az account show -s $subscriptionName -o tsv --query 'tenantId')" | sed "s/\r//")

# Get current user context object ID. Need this to set initial Key Vault Access Policy so secrets etc. can be set/read in these scripts.
export USER_OBJECT_ID=$(echo "$(az ad signed-in-user show -o tsv --query 'objectId')" | sed "s/\r//")

# Deployment
export LOCATION="eastus2"

# Resource Groups
export RG_NAME_SECURITY="$resourceNamingInfix""-security-""$LOCATION"
export RG_NAME_SIG="$resourceNamingInfix""-sig-""$LOCATION"
export RG_NAME_NET="$resourceNamingInfix""-net-""$LOCATION"
export RG_NAME_SOURCE="$resourceNamingInfix""-vm-source-""$LOCATION"
export RG_NAME_DEPLOY="$resourceNamingInfix""-vm-deploy-""$LOCATION"

# User-Assigned Managed Identity
export USERNAME_UAMI="$resourceNamingInfix""-vm-uami-""$LOCATION"

# Key Vault
export KEYVAULT_SKU_NAME="Standard"
export KEYVAULT_NAME="kv-""$resourceNamingInfix""-""$LOCATION"
export KEYVAULT_SOFT_DELETE="false"

# Network
export NSG_NAME="vm-nsg-""$LOCATION"
export VNET_NAME="vm-vnet-""$LOCATION"
export VNET_PREFIX="10.4.0.0/16"
export VNET_ENABLE_DDOS_PROTECTION="Disabled" # Enabled or Disabled
export VNET_ENABLE_VM_PROTECTION="Disabled" # Enabled or Disabled
export SUBNET_NAME="subnet1"
export SUBNET_PREFIX="10.4.1.0/24"
export SUBNET_SERVICE_ENDPOINTS=""
export SUBNET_PRIVATE_ENDPOINT_NETWORK_POLICIES="Enabled" # Enabled or Disabled
export SUBNET_PRIVATE_LINK_NETWORK_POLICIES="Enabled" # Enabled or Disabled

#SIG
export SIG_NAME="sig"

# Now assemble all the individual template paths
# ARM Templates
export TEMPLATE_UAMI="$templateRoot""identity.user-assigned-mi.json"
export TEMPLATE_KEYVAULT="$templateRoot""key-vault.json"
export TEMPLATE_KEYVAULT_SECRET="$templateRoot""key-vault.secret.json"
export TEMPLATE_NSG="$templateRoot""net.nsg.json"
export TEMPLATE_VNET="$templateRoot""net.vnet.json"
export TEMPLATE_SUBNET="$templateRoot""net.vnet.subnet.json"
export TEMPLATE_PUBLIC_IP="$templateRoot""net.public-ip.json"
export TEMPLATE_NIC="$templateRoot""net.network-interface.json"
export TEMPLATE_VM="$templateRoot""vm.linux.json"
export TEMPLATE_VM_EXTENSION_CUSTOM_SCRIPT="$templateRoot""vm.extension.custom-script.json"

# ##################################################

# VM
export HYPER_V_GENERATION="V1"
export OS_STATE="Generalized"

# ##################################################
# Three VM OS blocks are provided.
# All three OS disks are swappable.
# We use three OSes for the three versions here, but of course you can just use the same OS across your versions.
# I swap OSes here to also show how to vary OS offer and SKU. Totally optional, feel free to stick with your one happy OS across many image versions.
# ##################################################
# az vm image list-skus -l $LOCATION --publisher RedHat --offer RHEL -o tsv --query '[].name'
# ##################################################
export OS_PUBLISHER_1="Canonical"
export OS_OFFER_1="UbuntuServer"
export OS_SKU_1="18.04-LTS"

export OS_PUBLISHER_2="Canonical"
export OS_OFFER_2="0001-com-ubuntu-server-focal"
export OS_SKU_2="20_04-lts"

export OS_PUBLISHER_3="Canonical"
export OS_OFFER_3="0001-com-ubuntu-server-impish"
export OS_SKU_3="21_10"
# ##################################################
#export OS_PUBLISHER_1="RedHat"
#export OS_OFFER_1="RHEL"
#export OS_SKU_1="8_3"

#export OS_PUBLISHER_2="RedHat"
#export OS_OFFER_2="RHEL"
#export OS_SKU_2="8_4"

#export OS_PUBLISHER_3="RedHat"
#export OS_OFFER_3="RHEL"
#export OS_SKU_3="8_5"
# ##################################################

export VM_VERSION="latest"

export VM_ENABLE_ACCELERATED_NETWORKING="true" # This is not supported for all VM Sizes - check your VM Size!
export PROVISION_VM_AGENT="true"
export VM_SIZE="Standard_D4s_v3"

export VM_PUBLIC_IP_TYPE="Static" # Static or Dynamic - Standard SKU requires Static
export VM_PUBLIC_IP_SKU="Standard" # Basic or Standard

export PRIVATE_IP_ALLOCATION_METHOD="Dynamic"
export IP_CONFIG_NAME="ipConfig1"

export VM_TIME_ZONE="Eastern Standard Time"

export OS_DISK_STORAGE_TYPE="Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
export OS_DISK_SIZE_IN_GB=64
export DATA_DISK_STORAGE_TYPE="Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
export DATA_DISK_COUNT=0
export DATA_DISK_SIZE_IN_GB=1023
export VM_AUTO_SHUTDOWN_TIME="1800"
export VM_ENABLE_AUTO_SHUTDOWN_NOTIFICATION="Disabled" # Disabled | Enabled
export VM_AUTO_SHUTDOWN_NOTIFICATION_WEBHOOK_URL="" # Provide if set enableAutoShutdownNotification="Enabled"
export VM_AUTO_SHUTDOWN_NOTIFICATION_MINUTES_BEFORE=15

# Image source VMs - versions 2 and 3
export VM_SRC_NAME_V2="$resourceNamingInfix""-""$osInfix""-""$suffixVersion2"
export VM_SRC_NAME_V3="$resourceNamingInfix""-""$osInfix""-""$suffixVersion3"

# Deployed VMs
export VM_NAME_1="$resourceNamingInfix""-""$osInfix""-1"
export VM_1_OS_DISK_NAME_V1="$VM_NAME_1""-""$suffixVersion1"
export VM_1_OS_DISK_NAME_V2="$VM_NAME_1""-""$suffixVersion2"
export VM_1_OS_DISK_NAME_V3="$VM_NAME_1""-""$suffixVersion3"

export VM_NAME_2="$resourceNamingInfix""-""$osInfix""-2"
export VM_2_OS_DISK_NAME_V1="$VM_NAME_2""-""$suffixVersion1"
export VM_2_OS_DISK_NAME_V2="$VM_NAME_2""-""$suffixVersion2"
export VM_2_OS_DISK_NAME_V3="$VM_NAME_2""-""$suffixVersion3"

#SIG
export SIG_NAME="sig"
export VM_OS_TYPE="Linux" # Linux | Windows
export VM_IMG_DEF_NAME_V2="custom-""$osInfix""-""$OS_PUBLISHER_2""-""$OS_OFFER_2""-""$OS_SKU_2""-""$suffixVersion2"
export VM_IMG_DEF_VERSION_V2="1.0.0" # Could make this dynamic if, for example, generating more than one image version per image definition.
export VM_IMG_DEF_NAME_V3="custom-""$osInfix""-""$OS_PUBLISHER_3""-""$OS_OFFER_3""-""$OS_SKU_3""-""$suffixVersion3"
export VM_IMG_DEF_VERSION_V3="1.0.0" # Could make this dynamic if, for example, generating more than one image version per image definition.

export VM_IMG_NAME_V2="$VM_SRC_NAME_V2""-image"
export VM_IMG_NAME_V3="$VM_SRC_NAME_V3""-image"
# ##################################################
