#!/bin/bash

# ##################################################
# Variables only for this file - not exported to env vars

# The actual SSH key part - for convenience, using this in public keys for both deploy admin user as well as the new admin user
# that will be created on new VM post-deploy (see step 13)
sshPublicKeyInfix="AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw=="

# Change this as desired. Suggest making it indicative of the VM OS publisher configured below.
osInfix="ubu"

resourceNamingInfix="pz"
resourceNamingSuffix="-3"

# ARM Templates
# Use local files with az deployment group create --template-file
templateRootLocal="../../template/"
# Use files elsewhere with az deployment group create --template-uri
templateRootUri="https://raw.githubusercontent.com/plzm/azure-deploy/main/template/"
# Use this to choose local or remote templates
templateRoot=$templateRootUri # We will use remote template files via --template-uri
# Now assemble all the individual template paths

# ##################################################

# ##################################################
# Variables to export to env vars

# Provide at least these values
export NSG_RULE_INBOUND_100_SRC="75.68.47.183" # Leave empty to not add an inbound NSG rule for dev/test - see the net.nsg template
# Initial admin username
export ADMIN_USER_NAME="pelazem"
# New admin user to be added to VM in step13
export NEW_ADMIN_USER_NAME="newAdmin"

# In the form single-line, 'ssh-rsa key== username'
# Public SSH key for initial admin user
export ADMIN_SSH_PUBLIC_KEY="ssh-rsa ""$sshPublicKeyInfix"" ""$ADMIN_USER_NAME"

# In the form single-line, 'ssh-rsa key== username'
# Public SSH key for new admin user for step 13
# For convenience, re-using the same public key as above for initial deploy user... you will likely want to set a different public SSH key per user.
export NEW_ADMIN_SSH_PUBLIC_KEY="ssh-rsa ""$sshPublicKeyInfix"" ""$NEW_ADMIN_USER_NAME"

# Subscription ID. Can be hard-coded (first line), OR can use az account show (second line) to get the default subscription in current authentication context.
export SUBSCRIPTION_ID="4ca1851f-9d7a-456e-b346-1709991ecaff"
# SUBSCRIPTION_ID="$(az account show -o tsv --query 'id')"

# Get Tenant ID for Subscription. Need this to create User-Assigned Managed Identity and Key Vault.
export TENANT_ID="$(az account show --subscription ""$SUBSCRIPTION_ID"" -o tsv --query 'tenantId')"

# Get current user context object ID. Need this to set initial Key Vault Access Policy so secrets etc. can be set/read in these scripts.
export USER_OBJECT_ID="$(az ad signed-in-user show -o tsv --query 'objectId')"

# Deployment
export LOCATION="eastus2"

# Resource Groups
export RG_NAME_SECURITY="vm-security-""$LOCATION"
export RG_NAME_SIG="vm-sig-""$LOCATION"
export RG_NAME_NET="vm-net-""$LOCATION"
export RG_NAME_SOURCE="vm-source-""$LOCATION"
export RG_NAME_DEPLOY="vm-deploy-""$LOCATION"

# User-Assigned Managed Identity
export USERNAME_UAMI="$resourceNamingInfix""-vm-uami-""$LOCATION"

# Key Vault
export KEYVAULT_SKU_NAME="Standard"
export KEYVAULT_NAME="kv-""$resourceNamingInfix""-""$LOCATION""$resourceNamingSuffix"
export KEYVAULT_SECRET_NAME_ADMIN_USERNAME="vmAdminUsername"
export KEYVAULT_SECRET_NAME_ADMIN_SSH_PUBLIC_KEY="vmAdminSshPublicKey"
export KEYVAULT_SECRET_NAME_NEW_ADMIN_USERNAME="vmNewAdminUsername"
export KEYVAULT_SECRET_NAME_NEW_ADMIN_SSH_PUBLIC_KEY="vmNewAdminSshPublicKey"

# Network
export NSG_NAME="vm-test-nsg-""$LOCATION"
export VNET_NAME="vm-test-vnet-""$LOCATION"
export VNET_PREFIX="10.4.0.0/16"
export SUBNET_NAME="subnet1"
export SUBNET_PREFIX="10.4.1.0/24"

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

# VM
export HYPER_V_GENERATION="V1"
export OS_STATE="Generalized"

# ##################################################
# FOR CONVENIENCE, TWO VM OS BLOCKS PROVIDED.
# COMMENT ONE OUT.
# VM1 and VM2 are used for source images.
# VM3 is used for OS disk swaps. It is initially deployed with the oldest OS, then VM1 and VM2 are progressively newer versions to swap TO.
# Note that all three OS disks are swappable. So you can start with the VM3 OS disk, swap to VM1, VM2, and back to VM3, or as needed (no specific order is required).
# ##################################################
export OS_PUBLISHER="Canonical"
export OS_OFFER="UbuntuServer"
export OS_SKU_1="18.04-LTS"
export OS_SKU_2="20.04-LTS"
export OS_SKU_3="16.04-LTS"
# ##################################################
#export OS_PUBLISHER="RedHat"
#export OS_OFFER="RHEL"
#export OS_SKU_1="7.8"
#export OS_SKU_2="7_9"
#export OS_SKU_3="7.7"
# ##################################################

export VM_VERSION="latest"

export VM_ENABLE_ACCELERATED_NETWORKING="true" # This is not supported for all VM Sizes - check your VM Size!
export PROVISION_VM_AGENT="true"
export VM_SIZE="Standard_D4s_v3"

export VM_PUBLIC_IP_TYPE="Dynamic" # Static or Dynamic - Standard SKU requires Static
export VM_PUBLIC_IP_SKU="Basic" # Basic or Standard

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

# Source VMs
export VM1_NAME="pz-""$osInfix""-vm1"
export VM2_NAME="pz-""$osInfix""-vm2"
export VM1_PIP_NAME="$VM1_NAME""-pip"
export VM2_PIP_NAME="$VM2_NAME""-pip"
export VM1_NIC_NAME="$VM1_NAME""-nic"
export VM2_NIC_NAME="$VM2_NAME""-nic"

# Destination VM
export VM3_NAME="pz-""$osInfix""-vm3"
export VM3_PIP_NAME="$VM3_NAME""-pip"
export VM3_NIC_NAME="$VM3_NAME""-nic"
export VM3_OS_DISK_NAME_1="$VM3_NAME""-os-1"
export VM3_OS_DISK_NAME_2="$VM3_NAME""-os-2"
export VM3_OS_DISK_NAME_3="$VM3_NAME""-os-3"

#SIG
export SIG_NAME="sig"
export VM_OS_TYPE="Linux" # Linux | Windows
export VM_IMAGE_DEFINITION_1="custom-""$osInfix""-v1"
export VM_IMAGE_VERSION_1="1.0.0"
export VM_IMAGE_DEFINITION_2="custom-""$osInfix""-v2"
export VM_IMAGE_VERSION_2="1.0.0"

export VM1_IMAGE_NAME="$VM1_NAME""-image"
export VM2_IMAGE_NAME="$VM2_NAME""-image"
# ##################################################
