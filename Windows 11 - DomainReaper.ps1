<# This was created to automate the removal of machines from a Domain.

   1. Prompt for Domain Administrator Credentials
   2. Add Machine to Domain, Remove from Workgroup
   3. Forced System Restart (5 Second Countdown)

#>
# Prompt for Domain Administrator Credentials | Use your own AD Credentials here.
$domainCred = Get-Credential -Message "Enter Domain Administrator Credentials"

# Define Workgroup Name | Replace "LTTO" with whatever you would like. 
$workgroupName = "LTTO"

# Remove from Domain and Join Workgroup | No changes needed here -- let it be as is. 
Add-Computer -WorkGroupName $workgroupName -UnjoinDomainCredential $domainCred -Force -PassThru

# Notification: System Restart (Forced) | 
Write-Host "The system will restart in 5 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Forced Power-Cycle
Restart-Computer -Force
