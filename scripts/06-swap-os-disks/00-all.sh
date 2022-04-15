#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../set-env-vars.sh
./01-swap-os-disks-with-azure-cli.sh
