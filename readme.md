# Azure Deployment: Azure Virtual Machine (VM) - Non-Destructively Swap OS Disks

![01-Deploy-Infrastructure](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/01-deploy-infra.yml/badge.svg)  
![02-Deploy-Prod-VM](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/02-deploy-prod-vm.yml/badge.svg)  
![03-Create-Source-Image](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/03-create-source-image.yml/badge.svg)  
![04-Create-OS-Disks-From-Image](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/04-create-os-disks-from-image.yml/badge.svg?thisisto=refreshbadge)  
![05-Update-VM-Tag](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/05-update-vm-tag.yml/badge.svg?service=github)  
![06-Swap-OS-Disks](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/06-swap-os-disks.yml/badge.svg)  
![Cleanup](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/cleanup.yml/badge.svg)  

## Summary

This repo contains scripts and GitHub Actions (GHA) workflows (CD pipelines) for a complete implementation of non-destructive Azure VM OS disk swapping.

For details, background and motivation (what problem does this solve for whom), please see my blog post: https://plzm.blog/202204-vm-os-disk-swap

Comments below about making modifications to repository, scripts etc. assume you have forked this repo to your GitHub account.

The GHA workflows as well as the script folders, and scripts in the script folders, are all named sequentially. Scripts should be run in their sequential file name order (01-...sh first, then 02...sh, and so on).

Several script folders contain a `00-all.sh` script file, which runs the other scripts in that folder as well as shared scripts and other shared steps needed. Each `00-all.sh` script is designed to replicate the corresponding GHA workflow so you can easily work either in your local environment or in GHA.

## ARM Templates

The scripts in this repo use ARM templates that I maintain in another GitHub repo, [azure-deploy](https://github.com/plzm/azure-deploy). See my blog post [Modular and reusable ARM templates](https://plzm.blog/202104-modular-reusable-arm-templates) for more on my ARM templates.

## Repository Contents

### Set Environment Variables

[scripts/set-env-vars.sh](scripts/set-env-vars.sh)

This script sets all environment variables used by all the other scripts and GHA workflows in this repo.

To modify how any of the pieces of this implementation work, start by modifying this file to your needs.

The GHA workflows and the other scripts will each use _some_ of the environment variables set in this file. It is provided as one file for simplicity.

To work with the scripts in this repo in your local environment, dot-source this file first so that the environment variables are persistent in your shell session:

```bash
. ./set-env-vars.sh
```

This script sets environment variables both in a local development environment as well as a GitHub runner, such that successive GHA steps in the workflow can all access the environment variables. See my blog post [Don't Repeat Yourself: Environment Variables in GitHub Actions and locally](https://plzm.blog/202203-env-vars) for details.

### Create an Azure Service Principal

[scripts/create-service-principal.sh](scripts/create-service-principal.sh)

Use this script to create an Azure Service Principal in your Azure subscription.

You will need to persist the output of this script as a GitHub repository secret so that your GitHub workflows can authenticate to Azure and run commands there. See the [Azure Developer documentation](https://docs.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret) for how to do this.

> NOTE: you must do this before running the GHA workflows in this repo. Otherwise, your workflows will fail since your GitHub runner will not have an Azure authentication context.

### SSH Utility Scripts

[scripts/ssh/](scripts/ssh/)

Scripts to manage SSH keys and known hosts, and to add and remove Azure Network Security Group (NSG) rules allowing GitHub-hosted runners to SSH to Azure VMs.

This implementation uses the principle of least access to configure VMs by creating and using "transient" SSH keys for Azure VM deployment and configuration. These SSH keys (private and public pair) are used within the GHA workflow, and then removed from the VM as well as the local/runner environment after use. This ensures that the runner or the local environment _can no longer access the VM after deployment!_

For later production use, the workflow is provided a public SSH key _only_, for a "real" production user account to add to the VM. The corresponding private SSH key is never provided to the workflow. In this way, the workflow can deploy and configure a VM, and prepare it for eventual use by the "real" account, without the workflow or the GitHub runner or local environment ever having the "real" user account _private_ SSH key.

See my blog post [Using transient SSH keys on GitHub Actions Runners for Azure VM deployment and configuration](https://plzm.blog/202204-gha-ssh-vms) for details on this approach and when it is relevant, e.g. in highly regulated/compliant environments where certain Azure VM agents or extensions may not be available.

### VM Utility Scripts

[scripts/vmadmin/](scripts/vmadmin/)

Scripts to add and remove users from Azure VMs (really, any Ubuntu or compatible VM).

### 01 Deploy Infrastructure

Scripts directory: [scripts/01-deploy-infra/](scripts/01-deploy-infra/)
GHA workflow: [.github/workflows/01-deploy-infra.yml](.github/workflows/01-deploy-infra.yml)

Deploys foundational Azure infrastructure used throughout the implementation in this repo.

- [01-deploy-rgs.sh](scripts/01-deploy-infra/01-deploy-rgs.sh): Deploy Resource Groups
- [02-deploy-uami.sh](scripts/01-deploy-infra/02-deploy-uami.sh): User-Assigned Managed Identity (UAMI) which will be assigned to deployed production VM (see below)
- [03-deploy-network.sh](scripts/01-deploy-infra/03-deploy-network.sh): Virtual network with two subnets, one for image source VMs and one for production deployed VMs
- [03-deploy-network.sh](scripts/01-deploy-infra/03-deploy-network.sh): Network Security Groups (NSGs) for inbound access to source image and production subnets from local environment
  - You can set the local source IP address to an empty string to avoid the NSG rules for Azure VM SSH access being created
  - See [set-env-vars.sh](https://github.com/plzm/azure-vm-disk-swap/blob/main/scripts/set-env-vars.sh#L36)
- [04-deploy-compute-gallery.sh](scripts/01-deploy-infra/04-deploy-compute-gallery.sh): Azure Compute Gallery used to store custom VM images

You can run these scripts individually, or run [00-all.sh](scripts/01-deploy-infra/00-all.sh), or run the GHA workflow [01-deploy-infra.yml](.github/workflows/01-deploy-infra.yml), to deploy these infrastructure components so the remaining scripts and workflows work.

Alternately, if you have your own versions of these infrastructure components, you can use those. Just alter [set-env-vars.sh](scripts/set-env-vars.sh) appropriately so that the various scripts and workflows know how to find your existing infrastructure components.

### 02 Deploy Production VM

Scripts directory: [scripts/02-deploy-prod-vm/](scripts/02-deploy-prod-vm/)
GHA workflow: [.github/workflows/02-deploy-prod-vm.yml](.github/workflows/02-deploy-prod-vm.yml)

Deploys a production VM into its own Resource Group.

- [01-deploy-rgs.sh](scripts/02-deploy-prod-vm/01-deploy-rgs.sh): Deploy Resource Groups
- [02-deploy-prod-vm.sh](scripts/02-deploy-prod-vm/02-deploy-prod-vm.sh): Deploys production VM including a public IP address (PIP), network interface card (NIC) and the VM and OS disk
- [03-configure-prod-vm.sh](scripts/02-deploy-prod-vm/03-configure-prod-vm.sh): Connects to deployed VM via SSH and runs [remote-cmd.sh](scripts/02-deploy-prod-vm/remote-cmd.sh) on the VM

The deployed VM runs Ubuntu Linux VM, and is configured with the UAMI deployed in [02-deploy-uami.sh](scripts/01-deploy-infra/02-deploy-uami.sh). You can substitute other Linux distributions with minimal effort by modifying the Azure OS publisher, offering and SKU in [set-env-vars.sh](scripts/set-env-vars.sh).

The VM is configured for the production VM subnet deployed with the VNet in [03-deploy-network.sh](scripts/01-deploy-infra/03-deploy-network.sh).

> NOTE: VMs in this repo are deployed with public IP addresses. This is so that GitHub-hosted runners can connect to them. If your environment prohibits public IP addresses and public endpoints, you can still use everything here. You will just need to host your own GitHub runners in a network environment where they can connect to your private endpoint-only Azure VMs.

After the VM is deployed, a configuration script is run on it over SSH. The controller script is [03-configure-prod-vm.sh](scripts/02-deploy-prod-vm/03-configure-prod-vm.sh) and it runs [remote-cmd.sh](scripts/02-deploy-prod-vm/remote-cmd.sh) on the deployed Azure VM. As you will see, it is a simple script and you can modify it to run any normal installs, configurations etc. as needed on your deployed production VM.

> NOTE: This could also be done with the Azure remote script extension, but see my blog post [Using transient SSH keys on GitHub Actions Runners for Azure VM deployment and configuration](https://plzm.blog/202204-gha-ssh-vms) for a discussion of why this extension may not always be available, and why I used straight SSH access in this implementation.

The scripts in this directory or the corresponding [02-deploy-prod-vm.yml](.github/workflows/02-deploy-prod-vm.yml) GHA workflow do not need to be run ongoing, each time the below scripts or corresponding GHA workflows are run. This directory and workflow are here for convenience, to provide a durable VM which the following workflows and steps will use.

If you have your own durable VM which you would like to use with the following, simply modify [set-env-vars.sh](scripts/set-env-vars.sh) accordingly.

> NOTE: the production VM is deployed with a set of Azure tags; see [02-deploy-prod-vm.sh](https://github.com/plzm/azure-vm-disk-swap/blob/main/scripts/02-deploy-prod-vm/02-deploy-prod-vm.sh#L17). If you use your own Azure VM deployment approach, **ADD THESE TAGS TO YOUR VM** so that later steps work correctly!

### 03 Create Source Image

Scripts directory: [scripts/03-create-source-image/](scripts/03-create-source-image/)
GHA workflow: [.github/workflows/03-create-source-image.yml](.github/workflows/03-create-source-image.yml)

This is the first piece of the implementation in this repo that you can run on both an as-needed basis as well as on a recurring schedule.

Deploys the components needed to create a VM image and persist it to the Azure Compute Gallery deployed above in [01 Deploy Infrastructure](#01-deploy-infrastructure).

- [01-deploy-rgs.sh](scripts/03-create-source-image/01-deploy-rgs.sh): Deploy Resource Groups
- [02-create-image-definition.sh](scripts/03-create-source-image/02-create-image-definition.sh): Create a new [Azure Compute Gallery](https://docs.microsoft.com/azure/virtual-machines/shared-image-galleries) VM Image Definition
- [03-deploy-source-vm.sh](scripts/03-create-source-image/03-deploy-source-vm.sh): Deploys VM including a public IP address (PIP), network interface card (NIC) and the VM and OS disk; this VM will be used as a source for a new VM image
- [04-prepare-vm-for-capture.sh](scripts/03-create-source-image/04-prepare-vm-for-capture.sh):
  - runs [create-user.sh](scripts/vmadmin/create-user.sh) on the VM to add the "real" eventual VM user to the VM and enable SSH connections by this user (see above)
  - runs [remote-cmd.sh](scripts/03-create-source-image/remote-cmd.sh) on the VM for additional installs and configuration
- [05-capture-vm.sh](scripts/03-create-source-image/05-capture-vm.sh): Generalizes the source VM, then captures an image of it and associates it as a version of the VM Image Definition created above by [02-create-image-definition.sh](scripts/03-create-source-image/02-create-image-definition.sh)
- [06-cleanup.sh](scripts/03-create-source-image/06-cleanup.sh): Cleans up all VM image creation resources by deleting the Resource Group

This piece can be used as needed to create a new VM image for some specific purpose, for example to have VM images with specific installs or configuration available for integration or smoke tests.

It can also be used on a recurring schedule, for example to run automatically each month to generate new VM images to use as part of routine infrastructure refreshes with updated, patched images. My blog post [https://plzm.blog/202204-vm-os-disk-swap](https://plzm.blog/202204-vm-os-disk-swap) discusses a common scenario for this in regulated environments.

As discussed above, a "deployment only" user is used to deploy and configure the source VM. A set of SSH keys is generated just for this process.

A separate _public SSH key only_ needs to be provided to the GHA workflow for the eventual "real" VM user. I set this public key statically as an environment variable in [set-env-vars.sh](https://github.com/plzm/azure-vm-disk-swap/blob/main/scripts/set-env-vars.sh#L63), but of course you can alter this to retrieve the public SSH key from a configuration store or otherwise get it as is suitable.

This public SSH key for the "real" user is used in [04-prepare-vm-for-capture.sh](scripts/03-create-source-image/04-prepare-vm-for-capture.sh).

At the end of this set of scripts or GHA workflow, you will have a new image version in the Azure Compute Gallery. This image version can then be used to create new VM OS disks as needed.

### 04 Create OS Disks from Image

Scripts directory: [scripts/04-create-os-disks-from-image/](scripts/04-create-os-disks-from-image/)
GHA workflow: [.github/workflows/04-create-os-disks-from-image.yml](.github/workflows/04-create-os-disks-from-image.yml)

This piece can be run on an as-needed or recurring basis.

- [01-create-os-disks-from-image.sh](scripts/04-create-os-disks-from-image/01-create-os-disks-from-image.sh): iterates through existing VMs in the subscription and creates a new OS disk for each VM from the VM image created in [03 Create Source Image](#03-create-source-image)

How does this piece determine for which VMs to create a new OS disk? I use a tag `AutoRefresh` whose value is set to `true`. An Azure Resource Graph query returns all VMs which have this tag/value:

```bash
az graph query -q 'Resources | where type =~ "microsoft.compute/virtualmachines" and tags.AutoRefresh =~ "true"
```

The above line of script is only the `az graph query` part. The actual script is a bit more complex, as it projects only the fields I need into an array which I can then iterate through (the following fragment uses a `$SUBSCRIPTION_ID` environment variable):

```bash
vms="$(az graph query -q 'Resources | where type =~ "microsoft.compute/virtualmachines" and tags.AutoRefresh =~ "true" | project id, name, location, resourceGroup' --subscription ""$SUBSCRIPTION_ID"" --query 'data[].{id:id, name:name, location:location, resourceGroup:resourceGroup}')"
```

Each loop through `$vms` represents a VM in the subscription which has the tag `AutoRefresh=true`. For each such VM, the script determines a new OS disk name and then creates it, from the VM image created above in [03 Create Source Image](#03-create-source-image), in the same Resource Group as the VM. (Note the use of several environment variables in all-caps. These are all set in [set-env-vars.sh](scripts/set-env-vars.sh).)

```bash
while read -r id name location resourceGroup; do
	diskName="$name""-""$VM_SUFFIX_VNEXT"

	echo "Create vNext OS disk ""$diskName"" for VM ""$location""\\""$resourceGroup""\\""$name"
	az disk create --subscription "$SUBSCRIPTION_ID" -g "$resourceGroup" -l "$location" --verbose \
		-n "$diskName" --gallery-image-reference "$galleryImageRefVNext" \
		--os-type "$VM_OS_TYPE" --sku "$OS_DISK_STORAGE_TYPE"

done< <(echo "${vms}" | jq -r '.[] | "\(.id) \(.name) \(.location) \(.resourceGroup)"')

```

The outcome of this step is that each VM now has a new OS disk in its Resource Group. You can adjust the frequency at which you run this, how you select VMs for which to build new OS disks, and how you name the OS disks.

This repo does not implement cleanup logic to delete previous OS disk images. This can easily be done in another recurring process to delete OS disks that are more than three months old, for example.

### 05 Update VM Tag

Scripts directory: [scripts/05-update-vm-tag/](scripts/05-update-vm-tag/)
GHA workflow: [.github/workflows/05-update-vm-tag.yml](.github/workflows/05-update-vm-tag.yml)

This piece can be run on an as-needed or recurring basis.

- [01-tag-vms-with-new-os-disk-name.sh](scripts/05-update-vm-tag/01-tag-vms-with-new-os-disk-name.sh): selects VMs to update, and on each VM, updates the `OsDiskName` tag to the name of the next OS disk the VM should use

This piece is provided for recurring processes, such as automatically updating VMs each month with a new OS disk image with the latest updates.

VMs are selected with another Azure Resource Graph query which retrieves VMs that have the tag `AutoRefresh=true`, and also have the tag `OsDiskName`, but only with values that do not already end with the next OS disk name that should be used (some VMs may have been updated manually, or this process may be run multiple times, so we exclude already-updated VMs for efficiency).

```bash
query="Resources | where type =~ \"microsoft.compute/virtualmachines\" and tags['AutoRefresh'] =~ \"true\" and not(tags['OsDiskName'] endswith_cs \"""$VM_SUFFIX_VNEXT""\") | project id, name"

vms="$(az graph query -q "$query" --subscription "$SUBSCRIPTION_ID" --query 'data[].{id:id, name:name}')"
```

As in the previous step, we iterate through the resulting array of VMs and update the `OsDiskName` tag on each. Again, note the use of environment variables set in [set-env-vars.sh](scripts/set-env-vars.sh).


```bash
while read -r id name location resourceGroup
do
	tagValue="$name""-""$VM_SUFFIX_VNEXT"

	echo "Update VM ""$id"" OsDiskName tag to ""$tagValue"
	az tag update --subscription "$SUBSCRIPTION_ID" --resource-id "$id" --operation Merge --tags OsDiskName="$tagValue"

done< <(echo "${vms}" | jq -r '.[] | "\(.id) \(.name)"')
```

The outcome of this step is that eligible VMs now have their `OsDiskName` tag updated to reflect the OS disk name the VMs _should_ use. We haven't actually done the OS disk swap on these VMs yet!

### 06 Swap OS Disks

Scripts directory: [scripts/06-swap-os-disks/](scripts/06-swap-os-disks/)
GHA workflow: [.github/workflows/06-swap-os-disks.yml](.github/workflows/06-swap-os-disks.yml)

This piece can be run on an as-needed or recurring basis.

This step retrieves all VMs tagged with `AutoRefresh=true`, checks whether each VM needs an OS disk change, and if so, swaps the VM OS disk to the disk whose name is set on the `OsDiskName` tag.

```bash
vms="$(az graph query -q 'Resources | where type =~ "microsoft.compute/virtualmachines" and tags.AutoRefresh =~ "true" | project id, name, location, resourceGroup, currentOsDiskName=properties.storageProfile.osDisk.name, newOsDiskName=tags.OsDiskName' --subscription ""$SUBSCRIPTION_ID"" --query 'data[].{id:id, name:name, location:location, resourceGroup:resourceGroup, currentOsDiskName:currentOsDiskName, newOsDiskName:newOsDiskName}')"
```

Using a tag value is easier and more maintainable than, for example, setting a static value in a script or using a GitHub repository secret or other brittle, high-overhead approaches. It is very straightforward, for example, to grant a development team Contributor access in their Resource Group so they can set `OsDiskName` tag values themselves and run this script or GHA workflow to effect the OS disk change.

This step can be run as often as needed. As it checks each VM for whether an OS disk swap is even needed, it will only operate on VMs for which the swap is needed, and will not affect or change VMs if this is not true.

```bash
	if [[ -z $newOsDiskName ]]
	then
		echo "$location""/""$resourceGroup""/""$name"": OsDiskName tag is not set or value is empty. No change will be made to VM."
	elif [[ "$newOsDiskName" == "$currentOsDiskName" ]]
	then
		echo "$location""/""$resourceGroup""/""$name"": OS disk does NOT need to be changed. No change will be made to VM."
	else
		echo "$location""/""$resourceGroup""/""$name"": OS disk needs to be changed."

# ...etc. See script file linked above for details.
```

This piece [06 Swap OS Disks](#06-swap-os-disks) is separated from [05 Update VM Tag](#05-update-vm-tag) so that each can be run separately as needed for testing etc.

### Wrapup

This repo implements a complete process to periodically create and configure a new VM source image, without ability of the deployment infrastructure (GHA runner) to later access VMs based on the source image. Target VMs are identified and new OS disks built for each. Target VMs are automatically tagged for an OS disk swap, and the OS disk swap is automatically performed.

All this is done without deleting the immutable, stateless Azure resources: the VM or its PIP/NIC. This is very useful for the following reasons:

- Resilience: generate a new OS disk for a VM _in advance_
  - Enable testing of new OS disks to assure all functional and non-functional requirements are met
  - Minimize downtime while production VM is switched to a new OS disk
  - Maximize ability to fall back to the previous OS disk if any problems occur with the new OS disk
- Administration: minimize need to update allow lists, policy assignments, etc.
  - As the VM, PIP, and NIC are preserved, the VM's IP address can be maintained and dependencies do not need allow lists updated, as they may if the VM is simply deleted and a new VM, PIP and NIC need to then be generated
  - Minimize need to update any Azure Policy assignments for new Azure VM, PIP and NIC resources
  - Minimize need to wait for underlying Azure Resource Manager cleanup and other asynchronous processes after VM, PIP, or NIC delete

## NOTE

Feel free to examine, learn from, comment, and re-use (subject to the below) as needed and without intellectual property restrictions. If anything here helps you, attribution and/or a quick note is much appreciated.

---

### PLEASE NOTE FOR THE ENTIRETY OF THIS REPOSITORY AND ALL ASSETS

#### 1. No warranties or guarantees are made or implied

#### 2. All assets here are authored and provided by me "as is" - use at your own risk - validate before use

#### 3. I am not representing any employer or organization with these assets

#### 4. Use of the assets in this repo in your Azure environment may or will incur Azure usage and charges - you are completely responsible for monitoring and managing your Azure usage