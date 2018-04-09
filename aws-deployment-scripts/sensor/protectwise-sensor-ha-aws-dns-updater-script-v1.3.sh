#!/bin/bash

# Log output to syslog: Uncomment if output not already logged
# exec 1> >(logger -s -t $(basename $0)) 2>&1

# DNS updater script
# Maps the ProtectWise Sensor DNS name to the proper subnets via AWS CLI and Route53
# Based on the script by Will Warren at 
# https://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/
# This script starts at boot from /etc/rc.local
# Requires installation of AWS CLI and appropriate IAM access privileges

    # By default the script will create DNS A records for all subnets in the VPC the Sensor
    # boots in.  Otherwise uncomment the following variable and add the specific Subnet IDs this
    # Sensor is responsible for monitoring
    # SUBNETIDS=( subnet-xxxxxxxx subnet-yyyyyyyy subnet-zzzzzzzz )

# Internal Domain Name:
DOMAIN="example.com"

# Hosted Zone ID - below is the Route53 Zone ID for your domain:
ZONEID="xxxxxxxxxxxxxxxxx"

# Time-To-Live of the A Records:
TTL="60"

# No need to modify anything below

if [[ ${#SUBNETIDS[@]} -eq 0 ]]; then
    # SUBNETIDS variable not set, so automatically grab subnets from the VPC
    INTERFACEMAC=($(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/))
    VPCID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${INTERFACEMAC[0]}vpc-id)
    SUBNETIDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPCID" | grep -Po '"'"SubnetId"'"\s*:\s*"\K([^"]*)')
fi

TYPE="A"
IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
		
for SUBNET in ${SUBNETIDS[@]}; do
RECORDSET="sensor-$SUBNET.$DOMAIN"
COMMENT="Auto updating @ $(date)"	
TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
cat > ${TMPFILE} <<EOF
{ "Comment": "$COMMENT", "Changes": [{ "Action": "UPSERT", "ResourceRecordSet": { "ResourceRecords": [{ "Value": "$IP" }], "Name": "$RECORDSET", "Type": "$TYPE", "TTL": $TTL }}]} 
EOF

cat $TMPFILE

echo $(aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID \
    --change-batch file://"$TMPFILE")

rm $TMPFILE
done
