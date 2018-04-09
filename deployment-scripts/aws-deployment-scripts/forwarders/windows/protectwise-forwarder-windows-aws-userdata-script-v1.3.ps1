<powershell>
# ProtectWise Forwarding Agent Autoconfigurator Powershell Script for AWS

# Learn my subnet information
$captureInterfaceMac = Invoke-RestMethod http://169.254.169.254/latest/meta-data/network/interfaces/macs/
$SUBNET_ID = Invoke-RestMethod http://169.254.169.254/latest/meta-data/network/interfaces/macs/${captureInterfaceMac}subnet-id

# Create the forwarder.json config file
echo "{ `"sensor`": `"sensor-$SUBNET_ID`", `"filter`": `"not host 169.254.169.254`" }" | Out-File -FilePath "$env:ProgramFiles\ProtectWise Windows Forwarding Agent\config.json" -Encoding utf8

# Start the Forwarding Agent with the new config
Start-Service protectwise-forwarder

</powershell>
