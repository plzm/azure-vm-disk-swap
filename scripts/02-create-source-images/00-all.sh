#!/bin/bash

./01-deploy-rgs.sh
./02-prepare-ssh.sh
./03-create-image-definitions.sh
./04-deploy-source-vms.sh
./05-allow-gh-runner-ssh.sh
./06a-create-admin-user-with-azure-cli.sh
./07-prepare-vms-for-capture.sh
./08-capture-vms.sh
./09-cleanup-ssh-known-hosts.sh
./10-cleanup-ssh.sh
./11-cleanup.sh
