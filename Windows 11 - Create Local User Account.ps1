# EXECUTION POLICY FORCE (RemoteSigned, CurrentUser)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Validate Username
function Validate-Username {
    param ([string]$username)
    if (($username -eq "admin") -or ($username -eq "proxitadmin") -or ($username -match '^[A-Z][a-zA-Z]+[A-Z][a-zA-Z]+$')) {
        return $true
    } else {
        Write-Host "Invalid username format. Example: JSparrow, DRose, or valid exceptions such as admin or proxitadmin."
        return $false
    }
}

# Validate Password Length
function Validate-Password {
    param ([string]$password)
    if ($password.Length -eq 12) {
        return $true
    } else {
        Write-Host "Password must be exactly 12 characters."
        return $false
    }
}

# Account Parameter(s) Prompt
do {
    $username = Read-Host "Enter username (Format: FirstInitialLastName or valid exceptions e.g., admin, proxitadmin)"
} while (-not (Validate-Username $username))

do {
    $password = Read-Host -AsSecureString "Enter password (Exactly 12 characters)"
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
} while (-not (Validate-Password $passwordText))

$fullName = Read-Host "Enter full name"
$description = Read-Host "Enter description"

# Create LUA (Variable Dump)
New-LocalUser -Name $username -Password $password -FullName $fullName -Description $description

# Option for Administrator Privileges
$addToAdminGroup = Read-Host "Do you want to add the user to the administrators group? (yes/no)"
if ($addToAdminGroup -eq "yes") {
    Add-LocalGroupMember -Group "Administrators" -Member $username
    Write-Host "$username added to Administrators group."
} else {
    Write-Host "$username created without administrator privileges."
}
