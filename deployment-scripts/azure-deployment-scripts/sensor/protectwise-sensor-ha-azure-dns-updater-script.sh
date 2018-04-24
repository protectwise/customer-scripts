#!/bin/bash

# Log output to syslog: Uncomment if output not already logged
# exec 1> >(logger -s -t $(basename $0)) 2>&1

# DNS updater script for Azure
# Version 1.0
# Maps the ProtectWise Sensor DNS name to the proper subnets via Azure CLI and Azure DNS
# Based on the script by Will Warren at 
#   https://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/
#   https://gist.github.com/phybros/827aa561a44032dd1556
# This script starts at boot from /etc/rc.local
# Requires installation of Azure CLI and appropriate access privileges as well as jq (included in ProtectWise VHD)

    # By default the script will create DNS A records for all subnets in the vnet the Sensor
    # boots in.  Otherwise uncomment the following variable and add the specific Subnet IDs this
    # Sensor is responsible for monitoring (use dashes instead of dots for subnet names)
    # SUBNETIDS=( 10-0-0-0 10-1-1-0 10-50-35-0 )

# Internal Domain Name:
DOMAIN="example.com"

# Resource Group:
RESOURCEGROUP="MyResourceGroup"

# Vnet Name:
VNET="myVnet"

# Time-To-Live of the A Records:
TTL="60"

# No need to modify anything below

if [[ ${#SUBNETIDS[@]} -eq 0 ]]; then
    # SUBNETIDS variable not set, so automatically grab subnets from the vnet.  Transform dots to dashes for DNS.
    SUBNETIDS=($(echo $(az network vnet subnet list \
                    --resource-group "$RESOURCEGROUP" \
                    --vnet-name "$VNET" \
                    | jq -r .[].addressPrefix \
                    | tr '.' '-' \
                    | cut -f 1 -d '/')))
fi

IP=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")
	
for SUBNET in ${SUBNETIDS[@]}; do
    RECORDSET="sensor-$SUBNET"

    # First Delete the recordset if it already exists
    echo $(az network dns record-set a delete \
            --name "$RECORDSET" \
            --zone-name "$DOMAIN" \
            --resource-group "$RESOURCEGROUP" \
            --yes)

    # Then create new recordset
    echo $(az network dns record-set a create \
            --name "$RECORDSET" \
            --zone-name "$DOMAIN" \
            --resource-group "$RESOURCEGROUP" \
            --ttl $TTL)

    echo $(az network dns record-set a add-record \
            --record-set-name "$RECORDSET" \
            --ipv4-address "$IP" \
            --zone-name "$DOMAIN" \
            --resource-group "$RESOURCEGROUP")
done
