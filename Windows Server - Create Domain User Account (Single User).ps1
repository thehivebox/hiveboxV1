# Start

# Import Module
Import-Module ActiveDirectory

# Execution Policy: (RemoteSigned, CurrentUser, Force)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Function: Validate Username
function Validate Username {
    param ([string]$Username)
    if ($Username -match "^(admin.*|proxitadmin.*|[a-z]{1}[a-z]+)$") {
        return $true
    } else {
        Write-Host "Username does not coincide with username policy. Please try again." -ForegroundColor Red
        return $false
    }
}

# Function: Validate Full Name
function Validate-FullName {
    param ([string]$FullName)
    if ($FullName -match "^(admin.*|proxitadmin.*|[A-Z][a-z]+\s[A-Z][a-z]+)$") {
        return $true
    } else {
        Write-Host "Full name does not coincide with full name policy. Please try again." -ForegroundColor Red
        return $false
    }
}

# Function: Validate Password -> AD Password Policy = X
function Validate-Password {
    param ([securestring]$Password)
    try {
        [System.DirectoryServices.AccountManagement.PasswordValidator]::Validate($Password)
        return $true
    } catch {
        Write-Host "Password does not coincide with password policy. Please try again." -ForegroundColor Red
        return $false
    }
}

# Prompt: Username
$Attempts = 0
do {
    $Username = Read-Host "Enter the username."
    $Attempts++
    $IsValidUsername = Validate-Username $Username
    if ($Attempts -eq 2 -and -not $IsValidUsername) {
        Write-Host "Too many failed attempts. Closing PowerShell." -ForegroundColor Yellow
        exit
    }
} while (-not $IsValidUsername)

# Prompt: Full Name
$Attempts = 0
do {
    $FullName = Read-Host "Enter the full name."
    $Attempts++
    $IsValidFullName = Validate-FullName $FullName
    if ($Attempts -eq 2 -and -not $IsValidFullName) {
        Write-Host "Too many failed attempts. Closing PowerShell." -ForegroundColor Yellow
        exit
    }
} while (-not $IsValidFullName)

# Prompt: Password
$Attempts = 0
do {
    $Password = Read-Host "Enter the password." -AsSecureString
    $Attempts++
    $IsValidPassword = Validate-Password $Password
    if ($Attempts -eq 2 -and -not $IsValidPassword) {
        Write-Host "Too many failed attempts. Closing PowerShell." -ForegroundColor Yellow
        exit
    }
} while (-not $IsValidPassword)

# Create: AD User
Write-Host "Creating user in Active Directory..."
New-ADUser -SamAccountName $Username `
           -Name $FullName `
           -UserPrincipalName "$Username@yourdomain.com" `
           -AccountPassword $Password `
           -Enabled $true `
           -ChangePasswordAtLogon $true

Write-Host "User $Username created successfully." -ForegroundColor Green

# Display: AD Security Groups
Write-Host "Retrieving available security groups..." -ForegroundColor Cyan
$SecurityGroups = Get-ADGroup -Filter {GroupScope -eq 'Global' -and GroupCategory -eq 'Security'} | Select-Object -ExpandProperty Name
Write-Host "Available Security Groups:" -ForegroundColor Cyan
$SecurityGroups | ForEach-Object { Write-Host $_ }

# Display: AD Distribution Groups:
Write-Host "Retrieving available distribution groups..." -ForegroundColor Cyan
$DistributionGroups = Get-ADGroup -Filter {GroupScope -eq 'Universal' -and GroupCategory -eq 'Distribution'} | Select-Object -ExpandProperty Name
Write-Host "Available Distribution Groups:" -ForegroundColor Cyan
$DistributionGroups | ForEach-Object { Write-Host $_ }

# Prompt: Add to AD Group(s)
$SelectedGroups = Read-Host "Enter the groups (comma-separated | e.g. X,Y,Z) to add the user to:"
$GroupArray = $SelectedGroups -split ","
foreach ($Group in $GroupArray) {
    Add-ADGroupMember -Identity $Group.Trim() -Members $Username
    Write-Host "Added $Username to group $Group." -ForegroundColor Green
}

Write-Host "cdua.ps1 completed successfully." -ForegroundColor Green
