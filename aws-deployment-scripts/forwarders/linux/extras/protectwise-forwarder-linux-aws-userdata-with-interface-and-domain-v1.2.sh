#!/bin/bash
# ProtectWise Forwarding Agent Autoconfigurator Script for AWS
# Modify the following two variables for your environment:

# Capture interface on instance (default is eth0)
    CAPTURE_INTERFACE=eth0
# Domain name for the Sensors
    DNS_DOMAIN=example.com

# Learn my subnet information
captureInterfaceMac=$(ifconfig "${CAPTURE_INTERFACE}" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | tr '[:upper:]' '[:lower:]')
SUBNET_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/"${captureInterfaceMac}"subnet-id)

# Create the forwarder.json config file
configFile=/etc/protectwise/forwarder.json
echo "{" > "${configFile}"
echo "\"sensor\": \"sensor-${SUBNET_ID}.${DNS_DOMAIN}\"," >> "${configFile}"
echo "\"filter\": \"not host 169.254.169.254\"," >> "${configFile}"
echo "\"interfaces\": [ \"${CAPTURE_INTERFACE}\" ]" >> "${configFile}"
echo "}" >> "${configFile}"

# Start the Forwarding Agent with the new config
if which status; then start protectwise-forwarder
elif which systemctl; then systemctl start protectwise-forwarder
else service protectwise-forwarder start; fi
