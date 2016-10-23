#==============================================================================
# Remove-SiteDNS
# December 2010
# Ashley McGlone, Microsoft PFE
# http://blogs.technet.com/b/ashleymcglone
#
# This script cleans stale AD site DNS records by comparing the current AD site
# list to each DNS site record and deleting the ones where the site no longer
# exists.  Results are logged to a tab-delimited text file for documentation.
#
# If by some chance valid DNS records are purged simply restart the NetLogon
# service on all DCs in the affected site to re-register the records.  Note
# that this should not happen.
#
# If all root, child, and _msdcs zones are hosted on the forest root, then you
# should only have to run this once.  Otherwise you can rerun it for each
# child domain, targeting a DNS server and zone for each using the switches.
#
# Syntax:
# .\Remove-SiteDNS.ps1 -Zone foo.com -DNSServer dc1.foo.com -LogFile log.txt
# Add the -WhatIf switch the first time you run it to see what will be deleted.
# Running without switches will use the following defaults:
#  Zone - domain name of the forest root
#  DNSServer - PDC emulator of the forest root (assuming it is running DNS)
#  LogFile - DNSSitesLog.txt
#  WhatIf - Since no WhatIf switch is specified deletes will be active
#==============================================================================
Param (
    $Zone,
    $DNSServer,
    $LogFile,
    [switch]$WhatIf
)

# Clear errors and stop if any are encountered
$Error.psbase.clear()
$ErrorActionPreference = "Stop"

#==============================================================================
function ParseSiteNameFromDNSRecord {
# Take a DNS record string as a parameter
# Return just the site name portion of the data in lower case
    Param (
        $DNSRecord
    )

    # _kerberos._tcp.Bogus1._sites.wingtiptoys.local IN SRV 0 100 88 dca.wingtiptoys.local.
    $x = ($DNSRecord -split "._sites.")[0]
    # _kerberos._tcp.Bogus1
    $y = $x.split(".")
    $z = $y[-1]  # Last index of array
    # bogus1
    Return $z.toLower()
}
#==============================================================================

#==============================================================================
function CleanDNSSites {
# Take a zone name and DNS server as a parameter (required by WMI)
# Delete the invalid DNS entries
# Return the number of invalid site records in DNS
    Param (
        $Zone,
        $DNSServer
    )

    $DeleteCount = 0

    # This WMI query will return all DNS records on the server as long as the
    # end of the FQDN matches the parent zone.  In other words, even though
    # parentzone.com and child.parentzone.com may be stored in separate zones
    # on the server, this one WMI query will return all records that match
    # *.parentzone.com.  We filter these results for only the AD site DNS
    # records.
    $src = Get-WMIObject -ComputerName $DNSServer -Namespace 'root\MicrosoftDNS' `
           -Class MicrosoftDNS_ResourceRecord | Where-Object { `
           ($_.ContainerName -like "*$Zone") -and `
           ($_.TextRepresentation -like "*._sites.*")}

    ForEach ($srcRec in $src) {

        $DNSRecordText = $srcRec.TextRepresentation
        $DNSRecordSiteName = ParseSiteNameFromDNSRecord $DNSRecordText

        # If DNSRecordSiteName is not in the list of forest sites then delete.
        # Use lowercase and the semicolon delimiters to make sure we get an
        # exact match.
        If ($ADSiteList.Contains(";$DNSRecordSiteName;"))
            {
                "Valid`t$DNSRecordSiteName`t$DNSRecordText" | `
                    Out-File -FilePath $LogFile -Append
            }
        Else
            {
                ++$DeleteCount
                "Invalid`t$DNSRecordSiteName`t$DNSRecordText" | `
                    Out-File -FilePath $LogFile -Append
                If ($WhatIf)
                    # Leave the record
                    {   }
                Else
                    # Delete the record
                    { $srcRec.Delete()  }
            }
    }

    Return $DeleteCount
}
#==============================================================================


# Import AD cmdlets
# Normally we would put this on the first line of the script,
# but PARAM has to be on the first line.
Import-Module ActiveDirectory

# Normally we would specify parameter default values in the PARAM block,
# but we cannot initialize the AD cmdlets before the PARAM block.
# Default DNS zone name is the forest root domain name.
If ($Zone -eq $NULL) { $Zone = (Get-ADForest).RootDomain }
# Default DNS server name is the PDC emulator of the forest root.
# We assume it is running DNS, since we didn't get a parameter passed in.
If ($DNSServer -eq $NULL) { $DNSServer = (Get-ADDomain -Identity $Zone).PDCEmulator }
# Set default log file name.
If ($LogFile -eq $NULL) { $LogFile = "DNSSitesLog.txt" }

# Populate header data in log file.
"Start time: $(Get-Date)" | Out-File -FilePath $LogFile
"Zone:       $Zone" | Out-File -FilePath $LogFile -Append
"DNSServer:  $DNSServer" | Out-File -FilePath $LogFile -Append
"LogFile:    $LogFile" | Out-File -FilePath $LogFile -Append
"WhatIf:     $WhatIf" | Out-File -FilePath $LogFile -Append

# One-liner to put all of the forest AD sites into an array.
# We don't use the default collection, because it won't let us modify the
# values to lower case to guarantee an exact match in case the DNS records
# come back in all lower case.
# We create a single string list of all sites semicolon delimited for
# quicker matching later.
$ADSiteArray = @((Get-ADForest).Sites)
$ADSiteList = ";"
For ($i=0; $i -lt $ADSiteArray.length; $i++) {
    $ADSiteList += $ADSiteArray[$i].ToLower() + ";"
}
"AD Sites:   $ADSiteList" | Out-File -FilePath $LogFile -Append

# Call the main function and return the number of stale DNS entries.
$Total = CleanDNSSites $Zone $DNSServer

"Total Invalid:   $Total" | Out-File -FilePath $LogFile -Append
If ($WhatIf)
    { "Invalid site DNS entries logged only." | `
        Out-File -FilePath $LogFile -Append }
Else
    { "Invalid site DNS entries DELETED." | `
        Out-File -FilePath $LogFile -Append }

"End time:   $(Get-Date)" | Out-File -FilePath $LogFile -Append
