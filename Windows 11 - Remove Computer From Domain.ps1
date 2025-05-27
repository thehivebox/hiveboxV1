# This was created to automate the removal of machines from a Domain, add them to a specific Workgroup, and restart the computer for the changes to take affect while on-site. 
# Display Local Administrators to prevent potential lockout.
$admins = Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.PrincipalSource -eq "Local" }
$admins | Select-Object Name

# Check for the existence of the local admin account "lttoadmin"
$lttoadminExists = $admins | Where-Object { $_.Name -ieq "lttoadmin" }

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
    
    # Remove the computer from the domain, add it to the specified workgroup, and restart.
    Remove-Computer -UnjoinDomainCredential hivenode.com\hiveadmin -PassThru -Force -Verbose -WorkgroupName $workgroupName -Restart
} else {
    Write-Host "Operation cancelled by the user." -ForegroundColor Yellow
}



