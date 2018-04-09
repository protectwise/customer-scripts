ProtectWise Deployment Scripts

This folder includes sample scripts and template files to assist with deployments in IaaS environments, including AWS.

- AWS Deployment Scripts
    - Linux and Windows scripts and cloud formation templates used for automated deployments in AWS VPCs. This folder also includes
    a startup script and a cloudformation template for a simple HA solution for the sensor instance in a VPC utilizing Route53
    APIs and an autoscaling group of 1 configuration. In the future sample scripts and Lambda functions will be added to address
    automated remediation. (e.g. quarantine an instance via security group change or shut down an instance.)