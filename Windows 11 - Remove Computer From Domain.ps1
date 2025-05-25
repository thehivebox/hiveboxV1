<# This was created to automate the removal of machines from a Domain.

# Prompt for Domain Administrator Credentials | Use your own AD Credentials here.
$domainCred = Get-Credential 

# Remove from Domain 
Remove-Computer -UnjoinDomainCredential $domainCred -PassThru -Force

# Notification: System Restart (Forced) | 
Write-Host "The system will restart in 5 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Forced Power-Cycle
Restart-Computer -Force
