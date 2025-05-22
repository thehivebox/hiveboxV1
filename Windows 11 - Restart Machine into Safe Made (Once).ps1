# This was created to configure the system to boot into Safe Mode with Networking and revert the settings using Task Scheduler at next startup.

# Configure the system to boot into Safe Mode with Networking
# 'network' = Safe Mode with Networking
bcdedit /set {current} safeboot network

# Define the log file path
$logPath = "$env:SystemDrive\SafeModeBoot.log"
Add-Content -Path $logPath -Value "$(Get-Date): Configuring Safe Mode with Networking"

# Check for existing scheduled task and remove if exists
if (Get-ScheduledTask -TaskName "RevertSafeBoot" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName "RevertSafeBoot" -Confirm:$false
}

# Define the action for the scheduled task
# This action will run cmd.exe at startup and remove the Safe Mode setting via Powershell
$action = New-ScheduledTaskAction -Execute 'cmd.exe' `
    -Argument '/c powershell -ExecutionPolicy Bypass -Command "bcdedit /deletevalue {current} safeboot; Unregister-ScheduledTask -TaskName 'RevertSafeBoot' -Confirm:\$false"'

# Define the trigger for the scheduled task
# The task will run once at the next system startup
$trigger = New-ScheduledTaskTrigger -AtStartup

# Define the principal (user context) for the task
# Run as SYSTEM with the highest privileges to ensure it can modify boot settings
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Register the scheduled task with the system
# The task is named "RevertSafeBoot" and will execute once at startup
Register-ScheduledTask -TaskName "RevertSafeBoot" `
    -Action $action -Trigger $trigger -Principal $principal

# Restart the computer to apply Safe Mode with Networking 
Restart-Computer -Force
