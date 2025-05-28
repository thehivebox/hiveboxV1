# Display local Administrators to prevent potential lockout.
$admins = Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.PrincipalSource -eq "Local" }
$admins | Select-Object Name

# Check for the existence of the local admin account "lttoadmin".
# This handles names that might be prefixed with the computer name (e.g., "MYPC\lttoadmin").
$lttoadminExists = $admins | Where-Object { ($_.Name.Split("\")[-1]) -ieq "lttoadmin" }

if (-not $lttoadminExists) {
    Write-Host "Error: Local admin account 'lttoadmin' does not exist. The script will exit in 5 seconds." -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
} else {
    Write-Host "Local admin account 'lttoadmin' exists." -ForegroundColor Green
}

# Prompt the user for confirmation before proceeding.
$confirmation = Read-Host "Do you want to continue with removing the computer from the domain and changing the workgroup? (Yes/No)"

if ($confirmation -match "^(?i:y(es)?)$") {
    # Define variable for the new workgroup name.
    $workgroupName = "LTTO"
    
    # Remove the computer from the domain and add it to the specified workgroup.
    # Note: We are omitting the -Restart parameter here so we can control the restart timing.
    Remove-Computer -UnjoinDomainCredential hivenode.com\hiveadmin -PassThru -Force -Verbose -WorkgroupName $workgroupName
    
    Write-Host "Operation successful. Your machine will restart in 5 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    Restart-Computer -Force
} else {
    Write-Host "Operation cancelled by the user." -ForegroundColor Yellow
}
