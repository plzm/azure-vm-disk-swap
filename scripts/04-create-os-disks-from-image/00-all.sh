#!/bin/bash

scriptdir="$(dirname "$0")"
cd "$scriptdir"

../set-env-vars.sh
./01-create-os-disks-from-image.sh
