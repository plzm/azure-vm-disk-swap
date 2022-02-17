#!/bin/bash

./01-deploy-rgs.sh

./02-deploy-sig-image-definitions.sh

./03-deploy-source-vms.sh

./04a-create-admin-user-with-azure-cli.sh

#./05-ssh-to-source-vms.sh

#./06-capture-vms.sh

#./07-cleanup.sh
