# Azure Deployment: Azure Virtual Machine (VM) - Non-Destructively Swap OS Disks

![01-Deploy-Infrastructure](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/01-deploy-infra.yml/badge.svg)  
![02-Deploy-Prod-VM](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/02-deploy-prod-vm.yml/badge.svg)  
![03-Create-Source-Image](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/03-create-source-image.yml/badge.svg)  
![04-Create-OS-Disk-From-Image](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/04-create-os-disk-from-image.yml/badge.svg)  
![05-Swap-OS-Disk](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/05-swap-os-disk.yml/badge.svg)  
![Cleanup](https://github.com/plzm/azure-vm-disk-swap/actions/workflows/cleanup.yml/badge.svg)  

## Summary

This deployment shows how to create VM OS disk images, and to swap a VM's OS disk without deleting and re-creating the associated Azure resources (VM resource, Network Interface, Public IP, Data Disks).

Why is this useful?

- Periodically create new versions of OS disks with up-to-date patches and other configurations
- Maintain multiple environments for development, testing, etc.
- Create clean baseline OS installs for test suites and swap them without affecting/changing other Azure resources
- Fast fallback to a previous "known good" OS disk
- Etc.

## NOTE

As with all assets in this repo, usage is at your own risk. These assets (scripts, templates, etc.) are not supported by my employer. Please perform your own validation and testing as with any public web open source artifact. See [disclaimer](https://github.com/plzm/azure-deploy) at the root of this repo.
