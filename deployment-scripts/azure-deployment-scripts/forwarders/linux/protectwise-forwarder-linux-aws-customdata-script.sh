#!/bin/bash
# ProtectWise Forwarding Agent Autoconfigurator Script for Azure
# Version 1.0

# Learn my subnet information
SUBNET_ID=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/subnet/0/address?api-version=2017-08-01&format=text" | tr '.' '-')

# Create the forwarder.json config file
echo "{ \"sensor\": \"sensor-${SUBNET_ID}\", \"filter\": \"not host 169.254.169.254\" }" > /etc/protectwise/forwarder.json

# Start the Forwarding Agent with the new config
if which status; then start protectwise-forwarder
elif which systemctl; then systemctl start protectwise-forwarder
else service protectwise-forwarder start; fi
