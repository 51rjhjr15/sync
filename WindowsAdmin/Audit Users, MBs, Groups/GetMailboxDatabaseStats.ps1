#           by Gary Siepser http://blogs.technet.com/b/gary/archive/2009/11/11/mailbox-database-statistics.aspx
#	    .SYNOPSIS
#           This script gather statistics about Mailbox Databases
#
#           .DESCRIPTION
#           This script gathers the following database statistics about Exchange
#            2007 and above mailbox databases:
#           
#              - Mailbox Count on Database
#              - Database Physical FileSize
#              - Total of Mailbox Sizes
#             - Average Size of Mailboxes
#             - Largest Mailbox on Database
#            
#            The script also totals the gathered statistics from all databases
#            and adds the results to the end of the resultant array output.  This
#            Script outputs a custom object to the success pipeline and its
#            results can be piped to any typical cmdlet like export-csv or out-file
#           
#            This script was created by Gary Siepser of Microsoft.  This script is
#            provided "AS IS" with no warranties, and confers no rights.  Use of
#            any portion or all of this script are subject to the terms specified
#            at http://www.microsoft.com/info/cpyright.htm.
#   
#           .INPUTS
#           None. You cannot pipe objects to this script
#
#           .OUTPUTS
#           PSCustomObject with NoteProperties for each of the statistics
#
#           .EXAMPLE
#           C:\PS> .\script.ps1
#           
#            The script run alone will output in List format.
#
#           .EXAMPLE
#           C:\PS> .\script.ps1 | Format-Table -Autosize
#           
#            This example will out a formatted table of the results.
#
#           .EXAMPLE
#           C:\PS> .\script.ps1 | Export-Csv c:\export.csv
#           
#             This example will export the piplined object to a CSV file.
#
#           .EXAMPLE
#           C:\PS> Get-Help .\script.ps1 -Full
#           
#             This example will retrieve the full help of this script.



#Create an empty template object to be used as the blueprint of the final output objects
$TemplateObject = New-Object PSObject |
Select-Object DatabaseName,DatabaseFileSizeGB,TotalMailboxSizeGB,NumberofMailboxes,AverageMailboxSizeMB,MaxMailboxSizeMB


#Create the empty array to hold the Output Results
$ResultSet = @()

#Retrieve all DB Objects and loop through them
$databases = get-mailboxdatabase
foreach ($DB in $databases)
{
 
    #Create a copy of the Template
    $TempObject = $TemplateObject | Select-Object *
   
    #Get the DB File Size Info
    $DBRawFileInfo = get-wmiobject cim_datafile -computername $DB.server -filter ('name=''' + $DB.edbfilepath.pathname.replace("\","\\") + '''')
    $DBFileSize = [math]::Round([Decimal]( $DBRawFileInfo.filesize / 1GB),2)
   
    #Get Stats about the mailboxes in this database
    $AllMailboxstats = get-mailboxstatistics -database $DB.identity | Where-Object {$_.objectclass -eq "Mailbox"}
    $CombinedMailboxSizes = @()
    foreach ($mailbox in $AllMailboxstats)
    {
        $CombinedMailboxSizes += ($mailbox.totalitemsize.value.ToBytes() + $mailbox.totaldeleteditemsize.value.ToBytes())
    }
    $Stats = $CombinedMailboxSizes | Measure-Object -Average -Maximum -Sum
   
    #Save all this data we have into the template object
    $TempObject.DatabaseName = $DB.Name
    $TempObject.DatabaseFileSizeGB = $DBFileSize
    $TempObject.TotalMailboxSizeGB = [math]::Round($Stats.sum / 1GB ,2)
    $TempObject.NumberofMailboxes = $Stats.count
    $TempObject.AverageMailboxSizeMB = [math]::Round($Stats.average / 1MB,2)
    $TempObject.MaxMailboxSizeMB = [math]::Round($Stats.maximum / 1MB,2)
   
    #Add the TempObject to the Result Array for final output
    $ResultSet += $TempObject
}

#Compute Organizational Totals From Existing ResultSet

#Create a copy of the Template
$TempObject = $TemplateObject | Select-Object *

$AllDBFilesizeGB = $ResultSet | Measure-Object DatabaseFileSizeGB -Sum
$AllMailboxSizeGB = $ResultSet | Measure-Object TotalMailboxSizeGB -Sum
$AllMailboxCount = $ResultSet | Measure-Object NumberofMailboxes -Sum
$AllAverageMailboxSizeMB = $ResultSet | Measure-Object AverageMailboxSizeMB -Average
$AllMaxMailboxSizeMB = $ResultSet | Measure-Object MaxMailboxSizeMB -Max

#Save all this data we have into the template object
$TempObject.DatabaseName = "All Databases (Pre-Exchange 2007 not included)"
$TempObject.DatabaseFileSizeGB = $AllDBFilesizeGB.Sum
$TempObject.TotalMailboxSizeGB = $AllMailboxSizeGB.Sum
$TempObject.NumberofMailboxes = $AllMailboxCount.Sum
$TempObject.AverageMailboxSizeMB = $AllAverageMailboxSizeMB.Average
$TempObject.MaxMailboxSizeMB = $AllMaxMailboxSizeMB.Maximum

#Add the TempObject to the Result Array for final output
$ResultSet += $TempObject
    
$ResultSet 