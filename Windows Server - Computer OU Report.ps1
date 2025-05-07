# Load the AD Module
Import-Module ActiveDirectory

# Define the search base path for the "Computers" OU in the domain | replace "OU=Computers,DC=x,DC=x" with correct information.
$searchBase = "OU=Computers,DC=x,DC=x"

# Retrieve all computer objects in the specified OU | retrieve 'Name' and export the results to a CSV file.
Get-ADComputer -Filter * -SearchBase $searchBase |
    Select-Object Name |
    Export-Csv -Path "C:\temp\Computers.csv" -NoTypeInformation
