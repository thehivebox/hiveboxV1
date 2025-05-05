# EXECUTION POLICY FORCE (RemoteSigned, CurrentUser)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# VPN Parameter(s) Prompt
$vpnName = Read-Host "Enter VPN connection name:"
$serverAddress = Read-Host "Enter VPN server address [hostname, I.P. Address] (e.g., vpn.example.com):"
$sharedKey = Read-Host "Enter the shared key for L2TP/IPsec authentication:"

# Create the VPN connection
Add-VpnConnection -Name $vpnName -ServerAddress $serverAddress -TunnelType L2tp -AuthenticationMethod PAP -L2tpPsk $sharedKey -Force

#Open Network Control Panel
ncpa.cpl

Write-Host "L2TP VPN connection created successfully!"
