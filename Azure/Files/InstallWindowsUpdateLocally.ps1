param
(
    [parameter(Mandatory=$true)]
    [string]$StorageURL,

    [parameter(Mandatory=$false)]
    [string]$AutoReboot="yes"
)

function Expand-ZIPFile($file, $destination)
{
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items())
    {
       $shell.NameSpace($destination).copyhere($item)
    }
}

# Download the PSWindowsUpdate powershell module
$filePath = "C:\PSWindowsUpdate.zip"
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($StorageURL, $filePath)

# Extract the module to the Modules directory
$ModuleDirectory = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate"
md $ModuleDirectory
Expand-ZIPFile -file $filePath -destination $ModuleDirectory
Import-Module PSWindowsUpdate

# Get the List of windows updates available to a log file
Get-WUList -WindowsUpdate >> C:\WULogs.txt

# Install the available windows updates
If($AutoReboot -eq "yes")
{
    Get-WUInstall -WindowsUpdate -AcceptAll Software -AutoReboot
}
Else
{
    Get-WUInstall -WindowsUpdate -AcceptAll
}