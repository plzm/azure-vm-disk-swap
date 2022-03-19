#!/bin/bash
set -eux

./01-deploy-rgs.sh
./02-deploy-uami.sh
./03-deploy-network.sh
./04-deploy-compute-gallery.sh
