$Action    = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 0"
$Trigger   = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 17:00
$Settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries

$Task = New-ScheduledTask `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings

Register-ScheduledTask -TaskName "Restart Machine - Quality of Life (Weekly)" -InputObject $Task -RunLevel Highest -User "SYSTEM"
