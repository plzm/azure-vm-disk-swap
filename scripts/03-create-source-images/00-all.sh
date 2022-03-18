#!/bin/bash

./01-deploy-rgs.sh
./02-get-ssh-from-kv-set-local.sh
./03-create-image-definitions.sh
./04-deploy-source-vms.sh
./05a-create-admin-user-with-azure-cli.sh
#./06-prepare-vms-for-capture.sh
#./07-capture-vms.sh
#./08-cleanup.sh
#./09-cleanup-ssh.sh
