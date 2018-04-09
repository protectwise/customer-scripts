#!/bin/bash
# ProtectWise Forwarding Agent Autoconfigurator Script for AWS
# Version 1.3

# Learn my subnet information
captureInterfaceMac=($(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/))
SUBNET_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/"${captureInterfaceMac[0]}"subnet-id)

# Create the forwarder.json config file
echo "{ \"sensor\": \"sensor-${SUBNET_ID}\", \"filter\": \"not host 169.254.169.254\" }" > /etc/protectwise/forwarder.json

# Start the Forwarding Agent with the new config
if which status; then start protectwise-forwarder
elif which systemctl; then systemctl start protectwise-forwarder
else service protectwise-forwarder start; fi
