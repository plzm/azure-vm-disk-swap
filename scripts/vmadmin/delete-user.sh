#!/bin/bash
set -ux

vmUserName=$1

# Delete user
sudo userdel -rf "$vmUserName"
