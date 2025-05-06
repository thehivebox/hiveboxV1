#Created by Dakota Halvorson
#04/09/2025
#halvorsondakota@gmail.com
#DISCLAIMER: This script is provided as is without any warrant. The author is not liable for any damages or data loss resulting from its use. Use this script at your own risk.

#Start
# Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Display ASCII Art
Write-Host @"
                   .......................................   ..                                     
                   .====================================.  .********=.                              
                   .===================================   =************+.                           
                   .=================================:   +****************-                         
                   .================================.  .********************.                       
                   .===============================.  :**********************=                      
                   .=============================-   =************************=                     
                   .============================:   ***************************-                    
                   .===========================.  .*****************************.                   
                   .==========================   =******************************-                   
                   .========================-   +*******************************+                   
                   .=======================.  .*********************************+                   
                   .======================.  :**********************************=                   
                   .=====================   =***********************************:                   
                   .===================:   ************************************+                    
                   .==================.  .*************************************                     
                   .=================   -*************************************.                     
                   .===============-   +*************************************                       
                   .==============.  .*************************************-                        
                   .=============.  .************************************=                          
                   .===========-   -**********************************+.                            
                   .==========:   *******************************+=.                                
                   .=========.                                                                      
                   .========                                                                        
                   .======-                                                                         
                   .=====.                                                                          
                   .====.                                                                           
                   .==-                                                                             
                   .=-                                                                              
                   ..                                                                               
                                                                                                    
                                                                                                    
                                                                                                    
    .............                                                      ......  ..................   
    -==============-                                                   -****.  *****************.   
    -====.....:=====.                                                  -****.  ......*****.......   
    -====.     .====:  :==== -===.   .=========-    .=====.    =====:  -****.        *****          
    -====.     .====:  :=========. .======-=======    =====. .=====.   -****.        *****          
    -====.     :====.  :=====.     -====      ====.    .====-=====     -****.        *****          
    -===============   :====       -====      ====:      =======.      -****.        *****          
    -============..    :====       -====      ====:      .======       -****.        *****          
    -====.             :====       -====      ====:     =========.     -****.        *****          
    -====.             :====       :====.    .====    .===== .====-    -****.        *****          
    -====.             :====        :============.   -====:   .=====   -****.        *****          
                                        ..:...
"@ -ForegroundColor Cyan

Write-Host "`nActive Directory Grouper tool successfully deployed!"
# Function to display and validate all distribution groups within Proxit Groups OU
function DisplayAllDistributionGroups {
    $groups = Get-ADGroup -Filter "GroupCategory -eq 'Distribution'" -SearchBase "OU=Proxit Groups,DC=internal,DC=node1,DC=biz"
    if ($groups.Count -eq 0) {
        Write-Host "No distribution groups found in Proxit Groups OU."
    } else {
        Write-Host "Distribution Groups in Proxit Groups OU:"
        $i = 1
        $groups | ForEach-Object {
            Write-Host -NoNewline "$i. $($_.Name) "
            if ($i % 5 -eq 0) { Write-Host "" }  # Word wrapping after every 5 groups
            $i++
        }
        Write-Host ""  # Ensure new line at the end
    }
    return $groups
}

# Function to display and validate custom security groups within Proxit Groups OU
function DisplayCustomSecurityGroups {
    $groups = Get-ADGroup -Filter "GroupScope -eq 'Global' -and GroupCategory -eq 'Security'" -SearchBase "OU=Proxit Groups,DC=internal,DC=node1,DC=biz"
    if ($groups.Count -eq 0) {
        Write-Host "No custom Security groups found in Proxit Groups OU."
    } else {
        Write-Host "Custom Security Groups in Proxit Groups OU:"
        $i = 1
        $groups | ForEach-Object {
            Write-Host -NoNewline "$i. $($_.Name) "
            if ($i % 5 -eq 0) { Write-Host "" }  # Word wrapping after every 5 groups
            $i++
        }
        Write-Host ""  # Ensure new line at the end
    }
    return $groups
}

# Function to display and validate users in Proxit Users OU
function DisplayUsers {
    $users = Get-ADUser -Filter * -SearchBase "OU=Proxit Users,DC=internal,DC=node1,DC=biz"
    if ($users.Count -eq 0) {
        Write-Host "No users found in Proxit Users OU."
    } else {
        Write-Host "Users in Proxit Users OU:"
        $i = 1
        $users | ForEach-Object {
            Write-Host -NoNewline "$i. $($_.SamAccountName) "
            if ($i % 5 -eq 0) { Write-Host "" }  # Word wrapping after every 5 users
            $i++
        }
        Write-Host ""  # Ensure new line at the end
    }
    return $users
}

# Display and validate all distribution groups
$distributionGroups = DisplayAllDistributionGroups

# Display and validate custom security groups
$securityGroups = DisplayCustomSecurityGroups

# Display and validate users in Proxit Users OU
$users = DisplayUsers

# Function to prompt user selection with error checking
function PromptSelection {
    param (
        [string]$promptMessage,
        [int]$maxAttempts,
        [int]$maxValue
    )
    $attempts = 0
    while ($attempts -lt $maxAttempts) {
        $selection = Read-Host $promptMessage
        if ($selection -match "^\d+(,\d+)*$") {
            $indices = $selection -split ","
            $valid = $true
            foreach ($index in $indices) {
                if ($index -le 0 -or $index -gt $maxValue) {
                    $valid = $false
                    break
                }
            }
            if ($valid) {
                return $indices
            }
        }
        Write-Host "Invalid selection. Please try again."
        $attempts++
    }
    Write-Host "Maximum attempts reached. Exiting."
    exit
}

# Prompt user to select users
if ($users.Count -gt 0) {
    $userSelection = PromptSelection -promptMessage "Select users by entering the corresponding numbers separated by commas (e.g., 1,2,3)" -maxAttempts 3 -maxValue $users.Count
    $selectedUsers = @()
    foreach ($index in $userSelection) {
        $selectedUsers += $users[$index - 1]
    }

    # Prompt user to select distribution groups
    if ($distributionGroups.Count -gt 0) {
        $distGroupSelection = PromptSelection -promptMessage "Select distribution groups by entering the corresponding numbers separated by commas (e.g., 1,3,5)" -maxAttempts 3 -maxValue $distributionGroups.Count
        foreach ($index in $distGroupSelection) {
            if ($index -gt 0 -and $index -le $distributionGroups.Count) {
                $selectedDistGroup = $distributionGroups[$index - 1]
                foreach ($user in $selectedUsers) {
                    Add-ADGroupMember -Identity $selectedDistGroup -Members $user
                    Write-Host "User '$($user.SamAccountName)' added to distribution group '$($selectedDistGroup.Name)'."
                }
            } else {
                Write-Host "Invalid selection for distribution group."
            }
        }
    }

    # Prompt user to select security groups
    if ($securityGroups.Count -gt 0) {
        $secGroupSelection = PromptSelection -promptMessage "Select security groups by entering the corresponding numbers separated by commas (e.g., 2,4,6)" -maxAttempts 3 -maxValue $securityGroups.Count
        foreach ($index in $secGroupSelection) {
            if ($index -gt 0 -and $index -le $securityGroups.Count) {
                $selectedSecGroup = $securityGroups[$index - 1]
                foreach ($user in $selectedUsers) {
                    Add-ADGroupMember -Identity $selectedSecGroup -Members $user
                    Write-Host "User '$($user.SamAccountName)' added to security group '$($selectedSecGroup.Name)'."
                }
            } else {
                Write-Host "Invalid selection for security group."
            }
        }
    }
} else {
    Write-Host "No users found in Proxit Users OU."
}
