Get-ADComputer -Filter * -Prop IPv4Address | Where-Object { $_.IPv4Address -like "172.23.168.*" } | select -ExpandProperty name  | Out-File C:\temp\servers.txt  -Append

Get-ADComputer -Filter * -Prop IPv4Address | Where-Object { $_.IPv4Address -like "172.23.169.*" } | select -ExpandProperty name | Out-File C:\temp\servers.txt  -Append