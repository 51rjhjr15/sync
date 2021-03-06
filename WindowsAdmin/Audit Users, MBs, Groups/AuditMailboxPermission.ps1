Get-Mailbox -resultsize unlimited| 
Get-MailboxPermission | 
	where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | 
	Select Identity,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}} | 
	Export-Csv -NoTypeInformation c:\temp\mailboxpermissions.csv