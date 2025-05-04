$ConfigName = "Barracuda Cloud Archiving Service - bma_83ad52ce"
$BarracudaDomain = "mas.barracudanetworks.com"
$TenantId = "bma_83ad52ce-53a9-4de6-b02e-60ddc3bbacaf"

Import-Module -Name ExchangeOnlineManagement

$ErrorActionPreference = "Stop"

Connect-ExchangeOnline -ShowBanner:$False

function Set-BCASJournaling($RuleName, $BarracudaDomain, $TenantID, $Session) {
    $BarracudaAddress = "$TenantID@$BarracudaDomain"

    ### Configure remote domain
    $RemoteDomains = Get-RemoteDomain
    $SetNewRemoteDomain = $true
    $RemoteDomainToUpdate = $RuleName
    foreach ($Domain in $RemoteDomains) {
        if ($Domain.DomainName -eq $BarracudaDomain) {
            $SetNewRemoteDomain = $false
            $RemoteDomainToUpdate = $Domain.Name
            Break
        }
    }

    if ($SetNewRemoteDomain) {
        Write-Host "Configuring new Barracuda remote domain."
        New-RemoteDomain -Name $RuleName -DomainName $BarracudaDomain
    }
    else {
        Write-Host "Updating configuration of current Barracuda remote domain."
    }

    Set-RemoteDomain $RemoteDomainToUpdate -AutoReplyEnabled $false
    Set-RemoteDomain $RemoteDomainToUpdate -AllowedOOFType None
    Set-RemoteDomain $RemoteDomainToUpdate -AutoForwardEnabled $true
    Set-RemoteDomain $RemoteDomainToUpdate -DeliveryReportEnabled $false
    Set-RemoteDomain $RemoteDomainToUpdate -DisplaySenderName $false
    Set-RemoteDomain $RemoteDomainToUpdate -NDREnabled $false
    Set-RemoteDomain $RemoteDomainToUpdate -TNEFEnabled $false

    ### Configure outbound connector
    $OutboundConnectors = Get-OutboundConnector
    $SetNewConnector = $true
    foreach ($Connector in $OutboundConnectors) {
        if ($Connector.RecipientDomains -eq $BarracudaDomain -and $Connector.UseMXRecord -and $Connector.Enabled){
            $SetNewConnector = $false
            Break
        }
    }

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
    $Config = Get-TransportConfig
    $CurrentAddress = $Config.JournalingReportNdrTo
    if ($CurrentAddress -and $CurrentAddress -ne "<>") {
        Write-Host "Using previously configured undeliverable journal address."
    }
    else {
        ### Create a mailbox and set it as JournalingReportNdrTo
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
    $JournalRules = Get-JournalRule
    $SetNewRule = $true
    foreach ($Rule in $JournalRules) {
        if ($Rule.JournalEmailAddress -eq $BarracudaAddress -and $Rule.Enabled) {
            $SetNewRule = $false
            Break
        }
    }

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

Try {
    Set-BCASJournaling -BarracudaDomain $BarracudaDomain -RuleName $ConfigName -TenantId $TenantId
}
Catch {
    $host.ui.WriteErrorLine("Error caught in Set-BCASJournaling: $_")
}

Disconnect-ExchangeOnline -Confirm:$False