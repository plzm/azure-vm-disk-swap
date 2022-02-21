#!/bin/bash
# This is the script to run remotely on source VMs

touch i_was_here.txt

sudo mkdir /patrick_was_here

sudo chown -R root:root /patrick_was_here

# Other configuration etc. etc.

sudo waagent -deprovision+user -force
