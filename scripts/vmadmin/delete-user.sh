#!/bin/bash
set -eux

vmUserName=$1

# Delete user
sudo userdel -r "$vmUserName"
