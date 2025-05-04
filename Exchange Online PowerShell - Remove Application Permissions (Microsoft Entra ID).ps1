<#
    .SYNOPSIS
    Remove-AppPermissions.ps1

    .DESCRIPTION
    Remove app permissions from a Microsoft Entra ID application in a tenant.

    .LINK
    www.alitajran.com/remove-permissions-applications/

    .NOTES
    Written by: ALI TAJRAN
    Website:    alitajran.com
    X:          x.com/alitajran
    LinkedIn:   linkedin.com/in/alitajran

    .CHANGELOG
    V1.00, 11/08/2023 - Initial version
    V1.10, 10/07/2024 - Cleaned up the code
#>

# Variables
$systemMessageColor = "cyan"
$processMessageColor = "green"
$errorMessageColor = "red"
$warningMessageColor = "yellow"

Write-Host "Script started" -ForegroundColor $systemMessageColor
Write-Host "Script to delete app permissions from an Entra ID application in a tenant" -ForegroundColor $systemMessageColor

Write-Host "Checking for Microsoft Graph PowerShell module" -ForegroundColor $processMessageColor
if (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication) {
    Write-Host -ForegroundColor $processMessageColor "Microsoft Graph PowerShell module found"
}
else {
    Write-Host "Microsoft Graph PowerShell Module not installed. Please install and re-run the script" -ForegroundColor $warningMessageColor -BackgroundColor $errorMessageColor
    Write-Host "You can install the Microsoft Graph PowerShell module by:"
    Write-Host "1. Launching an elevated PowerShell console then,"
    Write-Host "2. Running the command, 'Install-Module -Name Microsoft.Graph'."
    Pause ## Pause to view error on screen
    exit 0 ## Terminate script
}

Connect-MgGraph -Scopes "User.ReadWrite.All", "Application.ReadWrite.All", "DelegatedPermissionGrant.ReadWrite.All" -NoWelcome

$results = Get-MgServicePrincipal -All | Select-Object Id, AppId, DisplayName | Sort-Object DisplayName | Out-GridView -PassThru -Title "Select Application (Multiple selections permitted)"
foreach ($result in $results) {
    # Loop through all selected options
    Write-Host "Commencing" $result.DisplayName -ForegroundColor $processMessageColor
    # Get Service Principal using objectId
    $sp = Get-MgServicePrincipal -All | Where-Object { $_.Id -eq $result.Id }
    # Menu selection for User or Admin consent types
    $consentType = [System.Collections.Generic.List[Object]]::new()
    $consentType.Add([PSCustomObject]@{ Name = "Admin consent"; Type = "allprincipals" })
    $consentType.Add([PSCustomObject]@{ Name = "User consent"; Type = "principal" })
    $consentSelects = $consentType | Out-GridView -PassThru -Title "Select Consent type (Multiple selections permitted)"

    foreach ($consentSelect in $consentSelects) {
        # Loop through all selected options
        Write-Host  "Commencing for" $consentSelect.Name -ForegroundColor $processMessageColor
        # Get all delegated permissions for the service principal
        $spOAuth2PermissionsGrants = Get-MgOauth2PermissionGrant -All | Where-Object { $_.clientId -eq $sp.Id }
        $info = $spOAuth2PermissionsGrants | Where-Object { $_.consentType -eq $consentSelect.Type }

        if ($info) {
            # If there are permissions set
            if ($consentSelect.Type -eq "principal") {
                # User consent
                $usernames = [System.Collections.Generic.List[Object]]::new()
                foreach ($item in $info) {
                    $usernames.Add((Get-MgUser -UserId $item.PrincipalId))
                }
                $selectUsers = $usernames | Select-Object Displayname, UserPrincipalName, Id | Sort-Object Displayname | Out-GridView -PassThru -Title "Select Consent type (Multiple selections permitted)"
                foreach ($selectUser in $selectUsers) {
                    # Loop through all selected options
                    $infoScopes = $info | Where-Object { $_.principalId -eq $selectUser.Id }
                    Write-Host $consentSelect.Name "permissions for user" $selectUser.Displayname -ForegroundColor $processMessageColor
                    foreach ($infoScope in $infoScopes) {
                        Write-Host "Resource ID =", $infoScope.ResourceId
                        $assignments = $infoScope.Scope -split " "
                        foreach ($assignment in $assignments) {
                            # Skip empty strings
                            if ($assignment -ne "") {
                                Write-Host "-", $assignment
                            }
                        }
                    }
                    Write-Host "Select items to remove" -ForegroundColor $processMessageColor
                    $removes = $infoScopes | Select-Object Scope, ResourceId, Id | Out-GridView -PassThru -Title "Select permissions to delete (Multiple selections permitted)"
                    foreach ($remove in $removes) {
                        Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $remove.Id
                        Write-Host "Removed consent for $($remove.Scope)" -ForegroundColor $warningMessageColor
                    }
                }
            }
            elseif ($consentSelect.Type -eq "allprincipals") {
                # Admin consent
                $infoScopes = $info | Where-Object { $_.principalId -eq $null }
                Write-Host $consentSelect.Name "permissions" -ForegroundColor $processMessageColor
                foreach ($infoScope in $infoScopes) {
                    Write-Host "Resource ID =", $infoScope.ResourceId
                    $assignments = $infoScope.Scope -split " "
                    foreach ($assignment in $assignments) {
                        # Skip empty strings
                        if ($assignment -ne "") {
                            Write-Host "-", $assignment
                        }
                    }
                }
                Write-Host "Select items to remove" -ForegroundColor $processMessageColor
                $removes = $infoScopes | Select-Object Scope, ResourceId, Id | Out-GridView -PassThru -Title "Select permissions to delete (Multiple selections permitted)"
                foreach ($remove in $removes) {
                    Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $remove.Id
                    Write-Host "Removed consent for $($remove.Scope)" -ForegroundColor $warningMessageColor
                }
            }
        }
        else {
            Write-Host "No" $consentSelect.Name "permissions found for" $results.DisplayName -ForegroundColor $warningMessageColor
        }
    }
}

Write-Host "Script Finished" -ForegroundColor $systemMessageColor
