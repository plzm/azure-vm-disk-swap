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

Scripts to deploy foundational Azure infrastructure used throughout the implementation in this repo:

- Resource Groups
- User-Assigned Managed Identity (UAMI) which will be assigned to deployed production VMs
- Virtual network with two subnets, one for image source VMs and one for production deployed VMs
- Network Security Groups (NSGs) for inbound access to Azure VMs from local environment (optional)
- Azure Compute Gallery used to store custom VM images

You can run these scripts individually, or run [00-all.sh](scripts/01-deploy-infra/00-all.sh), or run the GHA workflow [01-deploy-infra.yml](.github/workflows/01-deploy-infra.yml), to deploy these infrastructure components so the remaining scripts and workflows work.

Alternately, if you have your own versions of these infrastructure components, you can use those. Just alter [set-env-vars.sh](scripts/set-env-vars.sh) appropriately so that the various scripts and workflows know how to find your existing infrastructure components.

### 02 Deploy Production VM

Scripts directory: [scripts/02-deploy-prod-vm/](scripts/02-deploy-prod-vm/)
GHA workflow: [.github/workflows/02-deploy-prod-vm.yml](.github/workflows/02-deploy-prod-vm.yml)

Scripts to deploy a production VM into its own Resource Group.

The deployed VM runs Ubuntu Linux VM, and is configured with the UAMI deployed in [02-deploy-uami.sh](scripts/01-deploy-infra/02-deploy-uami.sh). You can substitute other Linux distributions with minimal effort by modifying the Azure OS publisher, offering and SKU in [set-env-vars.sh](scripts/set-env-vars.sh).

The VM is configured for the production VM subnet deployed with the VNet in [03-deploy-network.sh](scripts/01-deploy-infra/03-deploy-network.sh).

After the VM is deployed, a configuration script is run on it over SSH. The controller script is [03-configure-prod-vm.sh](scripts/02-deploy-prod-vm/03-configure-prod-vm.sh) and it runs [remote-cmd.sh](scripts/02-deploy-prod-vm/remote-cmd.sh) on the deployed Azure VM. As you will see, it is a simple script and you can modify it to run any normal installs, configurations etc. as needed on your deployed production VM.

> NOTE: This could also be done with the Azure remote script extension, but see my blog post [Using transient SSH keys on GitHub Actions Runners for Azure VM deployment and configuration](https://plzm.blog/202204-gha-ssh-vms) for a discussion of why this extension may not always be available, and why I used straight SSH access in this implementation.

The scripts in this directory or the corresponding [02-deploy-prod-vm.yml](.github/workflows/02-deploy-prod-vm.yml) GHA workflow do not need to be run ongoing, each time the below scripts or corresponding GHA workflows are run. This directory and workflow are here for convenience, to provide a durable VM which the following workflows and steps will use.

If you have your own durable VM which you would like to use with the following, simply modify [set-env-vars.sh](scripts/set-env-vars.sh) accordingly.

> NOTE: the production VM is deployed with a set of Azure tags; see [02-deploy-prod-vm.sh](https://github.com/plzm/azure-vm-disk-swap/blob/main/scripts/02-deploy-prod-vm/02-deploy-prod-vm.sh#L17). If you use your own Azure VM deployment approach, **ADD THESE TAGS TO YOUR VM** so that later steps work correctly!

### 03 Create Source Image

Scripts directory: [scripts/03-create-source-image/](scripts/03-create-source-image/)
GHA workflow: [.github/workflows/03-create-source-image.yml](.github/workflows/03-create-source-image.yml)



## NOTE

Feel free to examine, learn from, comment, and re-use (subject to the below) as needed and without intellectual property restrictions. If anything here helps you, attribution and/or a quick note is much appreciated.

---

### PLEASE NOTE FOR THE ENTIRETY OF THIS REPOSITORY AND ALL ASSETS

#### 1. No warranties or guarantees are made or implied.

#### 2. All assets here are authored and provided by me "as is". Use at your own risk. Validate before use.

#### 3. I am not representing my employer with these assets, and my employer assumes no liability whatsoever, and will not provide support, for any use of these assets.

#### 4. Use of the assets in this repo in your Azure environment may or will incur Azure usage and charges. You are completely responsible for monitoring and managing your Azure usage.