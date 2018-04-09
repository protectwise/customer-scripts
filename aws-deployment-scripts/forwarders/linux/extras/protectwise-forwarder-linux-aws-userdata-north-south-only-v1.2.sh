#!/bin/bash
# ProtectWise Forwarding Agent Autoconfigurator Script for AWS

# Learn my subnet information
captureInterfaceMac=($(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/))
SUBNET_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/"${captureInterfaceMac[0]}"subnet-id)
SUBNET_CIDR=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/"${captureInterfaceMac[0]}"subnet-ipv4-cidr-block)


# Create the forwarder.json config file
configFile=/etc/protectwise/forwarder.json
echo "{" > "${configFile}"
echo "\"sensor\": \"sensor-${SUBNET_ID}\"," >> "${configFile}"
echo "\"filter\": \"not (outbound and dst net ${SUBNET_CIDR}) or not (inbound and src net ${SUBNET_CIDR}) or not (host 169.254.169.254) or port 53 or udp port (67 or 68 or 546 or 547)\"" >> "${configFile}"
echo "}" >> "${configFile}"

# Start the Forwarding Agent with the new config
if which status; then start protectwise-forwarder
elif which systemctl; then systemctl start protectwise-forwarder
else service protectwise-forwarder start; fi
