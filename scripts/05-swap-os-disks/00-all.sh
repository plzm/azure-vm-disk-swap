#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../set-env-vars.sh
./01-tag-vms-with-new-os-disk-name.sh
./02-swap-os-disks-with-azure-cli.sh
