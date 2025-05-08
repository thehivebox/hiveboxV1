
# Import Module
Import-Module ActiveDirectory

# Execution Policy: (RemoteSigned, CurrentUser, Force)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Get all printers
$printers = Get-Printer

# Create an array to store printer details
$printerDetails = @()

# Loop through each printer and get its properties
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

    # Add the custom object to the array
    $printerDetails += $printerDetail
}

# Export the results to a CSV file
$printerDetails | Export-Csv -Path "c:\temp\PrintManagementResults.csv" -NoTypeInformation
