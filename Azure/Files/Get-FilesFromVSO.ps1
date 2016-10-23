<#
.SYNOPSIS 
    Gets all files in a VSO git repository to local folder.

.DESCRIPTION
    Gets all files in a VSO git repository to local folder
    
.PARAMETER VSOAccount
    Name of the account name for VSO Online.  Ex. https://accountname.visualstudio.com

.PARAMETER VSOBranch
    Optional name of the Git branch to retrieve the runbooks from.  Defaults to "master"

.PARAMETER VSOProject
    Name of the VSO project that contains the repository     

.PARAMETER VSORepository
    Name of the repository that contains the runbook project

.PARAMETER VSORunbookFolderPath
    Project path to the root where the runbooks are located.  Ex. /Project1/ProjectRoot
    where ProjectRoot contains the parent runbooks 

.PARAMETER VSOAuthUserName
    Alternate credentials for VSO: User Name 

.PARAMETER VSOAuthPassword
    Alternate credentials for VSO: Password  

.EXAMPLE
    .\Get-FilesFromVSO -VSOAccount "managedservicesdev" -VSORepository "ManagedServices" -VSOBranch "master" -VSOProject "ManagedServices" 
                     -VSOFolderPath "/SyncRunbooks" -VSOAuthUserName "amsrivasAltCredUser"  -VSOAuthPassword "Password" -DownloadFolderPath "C:\Test"   

#>

param (
       [Parameter(Mandatory=$false)]
       [string] $VSOAccount,

       [Parameter(Mandatory=$false)]
       [string] $VSORepository ,

       [Parameter(Mandatory=$false)]
       [string] $VSOProject,

       [Parameter(Mandatory=$false)]
       [string] $VSOBranch,
       
       [Parameter(Mandatory=$false)]
       [string] $VSOFolderPath,
       
       [Parameter(Mandatory=$false)]
       [string] $VSOAuthUserName,

       [Parameter(Mandatory=$false)]
       [string] $VSOAuthPassword,
       
       [Parameter(Mandatory=$false)]
       [string] $DownloadFolderPath

    )
    

    <#
	.Synopsis
		Writes the Log message to the log file with Time Stamp.
	.DESCRIPTION
		Writes the Log message to the log file with Time Stamp.
	.EXAMPLE
		Write-Log "Test Error"
	#>
	Function Write-Log
	{
		Param
		(
			# Specifies the message to be written to the log
			[Parameter(Mandatory=$true)]
			$LogEntry,
			[switch]
			$throw
		)
		
		# Write-Host $msg
		Out-File -InputObject "$(Get-Date) $LogEntry" -FilePath $LogFile -Append
		if ($throw)
		{
			throw $LogEntry
		}
	}


    $LogFile = "C:\GetVSOFiles.log"
    $fileExtension = "."
    $apiVersion = "1.0"
    $ErrorState = 0
    $ErrorMessage = "" 
    try
    {

    $ScriptName = $MyInvocation.MyCommand.ToString()
	$Message = "Started script: " + $ScriptName + "`n   User: " + $Env:Username
	Out-File -InputObject $Message -FilePath $LogFile

        #Creating authorization header using 
        $basicAuth = ("{0}:{1}" -f $VSOAuthUserName,$VSOAuthPassword)
        $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
        $basicAuth = [System.Convert]::ToBase64String($basicAuth)
        $headers = @{Authorization=("Basic {0}" -f $basicAuth)}
    
        #ex. "https://gkeong.visualstudio.com/defaultcollection/_apis/git/automation-git-test2-proj/repositories/automation-git-test2-proj/items?scopepath=/Project1/Project1/&recursionlevel=full&includecontentmetadata=true&versionType=branch&version=production&api-version=1.0-preview"
        $VSOURL = "https://" + $VSOAccount + ".visualstudio.com/defaultcollection/_apis/git/" + 
                $VSOProject + "/repositories/" + $VSORepository + "/items?scopepath=" + $VSOFolderPath +  
                "&recursionlevel=full&includecontentmetadata=true&versionType=branch&version=" + $VSOBranch +  
                "&api-version=" + $apiVersion
        Write-Log -LogEntry "Invoking RestMethod with URI: $VSOURL"        
        $results = Invoke-RestMethod -Uri $VSOURL -Method Get -Headers $headers
        Write-Log -LogEntry "Completed RestMethod with URI: $VSOURL. Results are: $results"  
        #grab folders only
        $folderObj = @()
        foreach ($item in $results.value)
        {
            if ($item.gitObjectType -eq "tree")
            {
                $folderObj += $item
            }
        }
    
        #recursively go through most inner child folders first, then their parents, parents parents, etc.
        for ($i = $folderObj.count - 1; $i -ge 0; $i--)
        {
            $folderURL = "https://" + $VSOAccount + ".visualstudio.com/defaultcollection/_apis/git/" + 
                    $VSOProject + "/repositories/" + $VSORepository + "/items?scopepath=" + $folderObj[$i].path +  
                    "&recursionLevel=OneLevel&includecontentmetadata=true&versionType=branch&version=" + 
                    $VSOBranch + "&api-version=" + $apiVersion
            Write-Log -LogEntry "Invoking RestMethod for current folder with URI: $folderURL"                
            $results = Invoke-RestMethod -Uri $folderURL -Method Get -Headers $headers
            Write-Log -LogEntry "Completed RestMethod for current folder with URI: $folderURL. Results are: $results"
            foreach ($item in $results.value)
            {
                if (($item.gitObjectType -eq "blob") -and ($item.path -match $fileExtension))
                {
                    $pathsplit = $item.path.Split("/")
                    $filename = $pathsplit[$pathsplit.Count - 1]
                    $outFile = Join-Path -Path $DownloadFolderPath -ChildPath $filename                    
                    Write-Log -LogEntry "Invoking RestMethod for current file with URI: $($item.url)"                
                    Invoke-RestMethod -Uri $item.url -Method Get -Headers $headers -OutFile $outFile
                    Write-Log -LogEntry "Cmpleted invokeing RestMethod for current file with URI: $($item.url)"
                }
            }
        }
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        Write-Log -LogEntry "ERROR: '$ErrorMessage'"
    }

