import-module c:\Windows\System32\WindowsPowerShell\v1.0\Modules\getinfo.psm1

$server = Get-Content C:\temp\servers.txt
ForEach ($server in Get-Content C:\temp\servers.txt) {

    Getinfo $server | Export-Csv c:\temp\serverdata.csv -Append
}
