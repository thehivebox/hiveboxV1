#This was created to automate the upgrade from Windows 10 to Windows 11 remotely (silent/unattended).

# Assign the directory path where the temporary files and logs will be stored.
# This creates a variable "$dir" containing the string "C:\temp\win11".
$dir = 'C:\temp\win11'

# Create the directory specified by "$dir". "mkdir" is an alias for New-Item -ItemType Directory.
# This ensures that the folder exists where the downloaded file and logs will be placed.
mkdir $dir

# Create a new instance of the .NET WebClient class.
# This object is used to perform web operations such as downloading files.
$webClient = New-Object System.Net.WebClient

# Set the URL of the Windows 11 Installation Assistant.
# The URL is a Microsoft link that automatically redirects to the current version of the installer.
$url = 'https://go.microsoft.com/fwlink/?linkid=2171764'

# Construct the full file path where the downloaded installer will be saved.
# The string is built using PowerShell's string interpolation to insert the value of "$dir".
$file = "$($dir)\Windows11InstallationAssistant.exe"

# Download the installer file from the specified URL and save it to the file path defined above.
# This is performed synchronously, meaning the script will wait until the download is complete.
$webClient.DownloadFile($url, $file)

# Start the Windows 11 Installation Assistant process with specific command-line arguments:
#   /QuietInstall   : Performs the installation silently without user interaction.
#   /SkipEULA       : Skips the End User License Agreement prompt.
#   /auto upgrade   : Automatically upgrades from Windows 10 to Windows 11.
#   /NoRestartUI    : Suppresses any restart user interface prompts.
#   /copylogs       : Saves log files to the specified directory for troubleshooting or record-keeping.
Start-Process -FilePath $file -ArgumentList "/QuietInstall /SkipEULA /auto upgrade /NoRestartUI /copylogs $dir"
