#!/bin/bash

./01-deploy-rgs.sh

./02-deploy-dest-vms.sh

sleep 600

./03-ssh-to-dest-vms.sh
