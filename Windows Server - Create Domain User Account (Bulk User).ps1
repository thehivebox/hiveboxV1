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

Write-Host "`nActive Directory On-boarding tool successfully deployed!"

#Start
# Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
# Define Domain
$domain = "internal.node1.biz"
# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt the user for the CSV file path
$csvFilePath = Read-Host "Enter the path to the CSV file"

# Import the CSV file
try {
    $users = Import-Csv -Path $csvFilePath
} catch {
    Write-Error "Error importing CSV file: $($_.Exception.Message)"
    exit
}

# Loop through each user in the CSV
foreach ($user in $users) {
    # Check if the user already exists
    if (Get-ADUser -Filter "SamAccountName -eq '$($user.SamAccountName)'") {
        Write-Warning "User '$($user.SamAccountName)' already exists. Skipping..."
    } else {
    
    # Create the user
        try {
            New-ADUser -SamAccountName $($user.SamAccountName) `
                       -Name "$($user.GivenName) $($user.Surname)" `
                       -GivenName $($user.GivenName) `
                       -Surname $($user.Surname) `
                       -DisplayName "$($user.Surname), $($user.GivenName)" `
                       -Path $($user.OU) `
                       -Enabled $true `
                       -AccountPassword (ConvertTo-SecureString $($user.Password) -AsPlainText -Force)
            Write-Host "User '$($user.SamAccountName)' created successfully."
        } catch {
            Write-Error "Error creating user '$($user.SamAccountName)': $($_.Exception.Message)"
        }
    }
}
