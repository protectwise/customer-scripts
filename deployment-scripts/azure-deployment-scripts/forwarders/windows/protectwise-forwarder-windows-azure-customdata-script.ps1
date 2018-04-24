<powershell>
# ProtectWise Forwarding Agent Autoconfigurator Powershell Script for Azure
# Version 1.0

# Learn my subnet information
$SUBNET_ID = Invoke-RestMethod -Headers @{"Metadata"="true"} -URI http://169.254.169.254/metadata/instance/network/interface/0/ipv4/subnet/0/address?api-version=2017-08-01&format=text -Method get | %{$_ -replace '.', '-'}

# Create the forwarder.json config file
echo "{ `"sensor`": `"sensor-$SUBNET_ID`", `"filter`": `"not host 169.254.169.254`" }" | Out-File -FilePath "$env:ProgramFiles\ProtectWise Windows Forwarding Agent\config.json" -Encoding utf8

# Start the Forwarding Agent with the new config
Start-Service protectwise-forwarder

</powershell>
