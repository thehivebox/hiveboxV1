# Define the URL of the file to be downloaded
$url = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"

# Define the path where the file will be saved
$output = "C:\temp\teamsbootstrapper.exe"

# Create a WebClient object
$webClient = New-Object System.Net.WebClient

# Download the file silently
$webClient.DownloadFile($url, $output)
