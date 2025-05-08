# Define configuration variables
$ConfigName = "Barracuda Cloud Archiving Service - bma_83ad52ce"
$BarracudaDomain = "mas.barracudanetworks.com"
$TenantId = ""

# Import the Exchange Online Management module
Import-Module -Name ExchangeOnlineManagement

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# Connect to Exchange Online without showing the banner
Connect-ExchangeOnline -ShowBanner:$False

# Define the function to set up Barracuda Cloud Archiving Service journaling
function Set-BCASJournaling($RuleName, $BarracudaDomain, $TenantID, $Session) {
    # Construct the Barracuda email address using the tenant ID and domain
    $BarracudaAddress = "$TenantID@$BarracudaDomain"

    ### Configure remote domain
    # Retrieve existing remote domains
    $RemoteDomains = Get-RemoteDomain
    $SetNewRemoteDomain = $true
    $RemoteDomainToUpdate = $RuleName
    foreach ($Domain in $RemoteDomains) {
        # Check if the Barracuda domain already exists
        if ($Domain.DomainName -eq $BarracudaDomain) {
            $SetNewRemoteDomain = $false
            $RemoteDomainToUpdate = $Domain.Name
            Break
        }
    }

    # Create or update the remote domain configuration
    if ($SetNewRemoteDomain) {
        Write-Host "Configuring new Barracuda remote domain."
        New-RemoteDomain -Name $RuleName -DomainName $BarracudaDomain
    }
    else {
        Write-Host "Updating configuration of current Barracuda remote domain."
    }

    # Set remote domain properties
    Set-RemoteDomain $RemoteDomainToUpdate -AutoReplyEnabled $false
    Set-RemoteDomain $RemoteDomainToUpdate -AllowedOOFType None
    Set-RemoteDomain $RemoteDomainToUpdate -AutoForwardEnabled $true
    Set-RemoteDomain $RemoteDomainToUpdate -DeliveryReportEnabled $false
    Set-RemoteDomain $RemoteDomainToUpdate -DisplaySenderName $false
    Set-RemoteDomain $RemoteDomainToUpdate -NDREnabled $false
    Set-RemoteDomain $RemoteDomainToUpdate -TNEFEnabled $false

    ### Configure outbound connector
    # Retrieve existing outbound connectors
    $OutboundConnectors = Get-OutboundConnector
    $SetNewConnector = $true
    foreach ($Connector in $OutboundConnectors) {
        # Check if the Barracuda outbound connector already exists and is enabled
        if ($Connector.RecipientDomains -eq $BarracudaDomain -and $Connector.UseMXRecord -and $Connector.Enabled){
            $SetNewConnector = $false
            Break
        }
    }

    # Create or use the existing outbound connector
    if ($SetNewConnector) {
        Write-Host "Configuring new Barracuda outbound connector."
        New-OutboundConnector -Name $RuleName `
            -RecipientDomains $BarracudaDomain  `
            -Comment "This connector is used to send journaling messages to the Barracuda Cloud Archiving Service." `
            -ConnectorType Partner `
            -TlsSettings EncryptionOnly `
            -Enabled $true
    }
    else {
        Write-Host "Using previously configured Barracuda outbound connector."
    }

    ### Configure undeliverable journal reports address
    # Retrieve current transport configuration
    $Config = Get-TransportConfig
    $CurrentAddress = $Config.JournalingReportNdrTo
    if ($CurrentAddress -and $CurrentAddress -ne "<>") {
        Write-Host "Using previously configured undeliverable journal address."
    }
    else {
        # Create a mailbox and set it as JournalingReportNdrTo if not already configured
        $DefaultAcceptedDomain = Get-AcceptedDomain | Where-Object{$_.Default -eq $true}
        $NDRAlias = "BarracudaNDR"
        $NDREmail = "$NDRAlias@$($DefaultAcceptedDomain.DomainName)"

        $ExistingNDRMailbox = Get-Mailbox -Filter "EmailAddresses -eq '$NDREmail'"
        if (-not $ExistingNDRMailbox) {
            New-Mailbox -Shared -Name "Barracuda NDR" -Alias $NDRAlias -PrimarySmtpAddress $NDREmail
            Set-TransportConfig -JournalingReportNdrTo $NDREmail
            Write-Host "Created mailbox '$NDREmail' and set as JournalingReportNdrTo"
        }
        else {
            Set-TransportConfig -JournalingReportNdrTo $NDREmail
            Write-Host "Set mailbox '$NDREmail' as JournalingReportNdrTo"
        }
    }

    ### Set up journal rule
    # Retrieve existing journal rules
    $JournalRules = Get-JournalRule
    $SetNewRule = $true
    foreach ($Rule in $JournalRules) {
        # Check if the Barracuda journal rule already exists and is enabled
        if ($Rule.JournalEmailAddress -eq $BarracudaAddress -and $Rule.Enabled) {
            $SetNewRule = $false
            Break
        }
    }

    # Create or use the existing journal rule
    if ($SetNewRule) {
        Write-Host "Configuring new Barracuda journal rule."
        New-JournalRule -Name $RuleName `
            -Scope Global `
            -JournalEmailAddress $BarracudaAddress `
            -Enabled $true
    }
    else {
        Write-Host "Using previously configured Barracuda journal rule."
    }
}

# Try to execute the function and catch any errors
Try {
    Set-BCASJournaling -BarracudaDomain $BarracudaDomain -RuleName $ConfigName -TenantId $TenantId
}
Catch {
    $host.ui.WriteErrorLine("Error caught in Set-BCASJournaling: $_")
}

# Disconnect from Exchange Online without confirmation
Disconnect-ExchangeOnline -Confirm:$False
