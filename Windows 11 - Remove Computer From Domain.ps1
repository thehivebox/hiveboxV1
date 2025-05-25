<# This was created to automate the removal of machines from a Domain, add them to a specific Workgroup, and restart the computer for the changes to take affect.

# Define variable for workgroup name
$workgroupName = "LTTO"

# Remove Computer from Domain 
Remove-Computer -UnjoinDomainCredential hivenode.com\hiveadmin -PassThru -Force -Verbose -WorkgroupName $workgroupName -Restart


