#!/bin/bash
# This is the script to run remotely on source VMs

sudo mkdir /patrick_was_here
sudo chown -R root:root /patrick_was_here  # This is so it doesn't get deleted as part of user deprovisioning

# Other configuration etc. etc.

sudo waagent -deprovision+user -force
