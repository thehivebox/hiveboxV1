# EXECUTION POLICY FORCE (RemoteSigned, CurrentUser)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# BitEnable
Enable-BitLocker -MountPoint "C:" -RecoveryPasswordProtector -SkipHardwareTest

# BitRetrieve
$recoveryKey = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}

# Recovery Key Save Location Parameter(s) Prompt
Write-Host "Where would you like to save the BitLocker recovery key?"
Write-Host "1: Save to a UNC network share path (e.g., \\ServerName\ShareFolder)"
Write-Host "2: Save to a USB or external storage device"
$saveOption = Read-Host "Enter the option number (1 or 2)"

if ($saveOption -eq "1") {
    # Prompt for UNC Network Share Path
    $networkSharePath = Read-Host "Enter the full UNC path (e.g., \\ServerName\ShareFolder)"
    
    # Construct File Path for Recovery Key
    $keyFilePath = $networkSharePath + '\' + $env:COMPUTERNAME + '.txt'

    # Save Recovery Key to Network Share Path
    $recoveryKey.RecoveryPassword | Out-File -FilePath $keyFilePath

    # Confirmation Message
    Write-Host "The BitLocker recovery key has been saved to the network share at $keyFilePath."

} elseif ($saveOption -eq "2") {
    # Prompt for USB or External Storage Path
    $usbPath = Read-Host "Enter the full path of the USB or external storage device (e.g., E:\)"
    
    # Construct File Path for Recovery Key
    $keyFilePath = $usbPath + '\' + $env:COMPUTERNAME + '.txt'

    # Save Recovery Key to USB/External Device
    $recoveryKey.RecoveryPassword | Out-File -FilePath $keyFilePath

    # Confirmation Message
    Write-Host "The BitLocker recovery key has been saved to the USB or external storage device at $keyFilePath."

} else {
    # Error Handler
    Write-Host "Invalid option selected. Please run the script again and select a valid option."
}

