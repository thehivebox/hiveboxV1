<# This script was created to provide details about the Deployed Printers within Print Management on a Windows Server. The .CSV was supplied to third-party vendor to assist their printer replacement/installation(s) while on-site. #>

# Import Module
Import-Module ActiveDirectory

# Execution Policy: (RemoteSigned, CurrentUser, Force)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Give me all the Printers
$printers = Get-Printer

# Array for Printer Deets
$printerDetails = @()

# Printer Loop | Property Hunter
foreach ($printer in $printers) {
    $printerName = $printer.Name
    $printerProperties = Get-PrinterProperty -PrinterName $printerName

    # Create a custom object to store the required printer details
    $printerDetail = [PSCustomObject]@{
        Name = $printer.Name
        DriverName = $printer.DriverName
        IPAddress = ($printerProperties | Where-Object {$_.Name -eq 'PortName'}).Value
        MakeModel = $printer.ShareName
        DeploymentDate = $printer.CreationTime
    }

    # Add Custom PrinterDetail Object to Array
    $printerDetails += $printerDetail
}

# Export PrinterDetail(s) to PrintManagementResults.csv on c:\temp. 
$printerDetails | Export-Csv -Path "c:\temp\PrintManagementResults.csv" -NoTypeInformation
