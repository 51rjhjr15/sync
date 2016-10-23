Get-Mailbox -ResultSize unlimited | Select-Object DisplayName, samaccountname, IssueWarningQuota, ProhibitSendQuota, @{label="TotalItemSize(MB)";expression={(Get-MailboxStatistics $_).TotalItemSize.Value.ToMB()}}, @{label="ItemCount";expression={(Get-MailboxStatistics $_).ItemCount}}, Database,primarysmtpaddress|Export-Csv "C:\temp\UserMailboxSizes.csv" -NoTypeInformation