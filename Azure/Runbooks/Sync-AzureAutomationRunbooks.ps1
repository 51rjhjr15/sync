<#
.SYNOPSIS 
    Syncs all runbooks in a VSO git repository to an Azure Automation account.

.DESCRIPTION
    Syncs all runbooks in a VSO git repository to an Azure Automation account starting with dependent (child)
    runbooks and followed by parent runbooks to an existing Automation Account.  This runbook will recursively
    treat all sub directories within the VSORunbookFolderPath as dependent (child) runbooks and publish these 
    first
    
    Requires a VSO Alternate Authentication Credential for connecting with VSO-Git repository, stored 
    in a Automation credential asset.
    
    This runbook has a dependency on Azure-Connect, The Azure-Connect runbook must be published for this runbook to run correctly
        
.PARAMETER VSOCredentialName
    Name of the credential asset containing the VSO Alternate Authentication Credential name 
    and password configured from VSO Profile dialog.
    
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

.PARAMETER ResourceGroupName
    Name of the resource group of the automation account.

.PARAMETER AutomationAccount
    Name of the Automation Account where the runbooks should be synced to

.PARAMETER DeleteExistingRunbook
    If "Yes", it deletes the existing runbook in the automation account runbook along will all the associated jobs and logs, and then imports the runbook from VSO.
    If "No", it imports the runbook from VSO if it is not already existing in Automation account. If the runbook already exists, it does not overwrite it.   
        
.PARAMETER AzureSubscriptionName
    Name of the Azure subscription.
 
.PARAMETER OrgIDCredential
    Name of the Azure credential asset that was created in the Automation service.
    This credential asset contains the user id & passowrd for the user who is having access to
    the azure subscription.    
   
.EXAMPLE
    Sync-AzureAutomationRunbooks -VSOCredentialName "vsoCredentialAmit" -VSOAccount "managedservicesdev" -VSORepository "ManagedServices"
    -VSOBranch "master" -VSOProject "ManagedServices" -VSORunbookFolderPath "/SyncRunbooks" -ResourceGroupName "TestARMResourceGroup" -AutomationAccount "TestARMAccount" 
    -DeleteExistingRunbook "Yes" -AzureSubscriptionName "Gopi -AzureSubscription" -OrgIDCredential "AutomationUser"      

#>
workflow Sync-AzureAutomationRunbooks
{
    param (
       [Parameter( Mandatory=$true)]
       [string] $VSOCredentialName,

       [Parameter( Mandatory=$true)]
       [string] $VSOAccount ,

       [Parameter( Mandatory=$true)]
       [string] $VSOProject,

       [Parameter( Mandatory=$true)]
       [string] $VSORepository,

       [Parameter( Mandatory=$true)]
       [string] $VSORunbookFolderPath,
       
       [Parameter( Mandatory=$true)]
       [string] $VSOBranch,
       
       [Parameter( Mandatory=$true)]
       [string] $ResourceGroupName,
       
       [Parameter( Mandatory=$true)]
       [string] $AutomationAccount,
       
       [Parameter( Mandatory=$true)]
       [string] $DeleteExistingRunbook,

       [Parameter( Mandatory=$true)]
       [string] $OrgIDCredential,
       
       [Parameter( Mandatory=$true)]
       [string] $AzureSubscriptionName
    )
    Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Sync-AzureAutomationRunbooks*****************`r`nInput params:, `r`n VSOCredentialName = $VSOCredentialName, `r`n VSOAccount = $VSOAccount, `r`n VSOProject = $VSOProject, `r`n VSORepository = $VSORepository, `r`n VSORunbookFolderPath = $VSORunbookFolderPath, `r`n VSOBranch = $VSOBranch, `r`n ResourceGroupName = $ResourceGroupName, `r`n AutomationAccount = $AutomationAccount, `r`n DeleteExistingRunbook = $DeleteExistingRunbook, `r`n OrgIDCredential = $OrgIDCredential, `r`n AzureSubscriptionName = $AzureSubscriptionName `r`n" -RunbookName Sync-AzureAutomationRunbooks        

    $psExtension = ".ps1"
    $apiVersion = "1.0"
    $ErrorState = 0
    $ErrorMessage = ""     
    try
    {        
        #Import and Publish the Connect-Azure runbook first     
        if ($OrgIDCredential)
        {            
            Write-Log -Level 15 -Message "Invoking command: Connect-Azure -OrgIDCredential $OrgIDCredential" -RunbookName Sync-AzureAutomationRunbooks
            Connect-Azure -OrgIDCredential $OrgIDCredential
        }
        Select-AzureSubscription -SubscriptionName $SubscriptionName -Verbose

        #Getting Credentail asset for VSO alternate authentication credentail
        $VSOCred = Get-AutomationPSCredential -Name $VSOCredentialName
        if ($VSOCred -eq $null)
        {
            Write-Log -Level 15 -Message "Could not retrieve '$VSOCredentialName' credential asset. Check that you created this asset in the Automation service." -RunbookName Sync-AzureAutomationRunbooks -IsError 
            throw "Could not retrieve '$VSOCredentialName' credential asset. Check that you created this asset in the Automation service."
        }
        $VSOAuthUserName = $VSOCred.UserName
        $VSOAuthPassword = $VSOCred.GetNetworkCredential().Password
        
        #Creating authorization header using 
        $basicAuth = ("{0}:{1}" -f $VSOAuthUserName,$VSOAuthPassword)
        $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
        $basicAuth = [System.Convert]::ToBase64String($basicAuth)
        $headers = @{Authorization=("Basic {0}" -f $basicAuth)}
    
        #ex. "https://gkeong.visualstudio.com/defaultcollection/_apis/git/automation-git-test2-proj/repositories/automation-git-test2-proj/items?scopepath=/Project1/Project1/&recursionlevel=full&includecontentmetadata=true&versionType=branch&version=production&api-version=1.0-preview"
        $VSOURL = "https://" + $VSOAccount + ".visualstudio.com/defaultcollection/_apis/git/" + 
                $VSOProject + "/repositories/" + $VSORepository + "/items?scopepath=" + $VSORunbookFolderPath +  
                "&recursionlevel=full&includecontentmetadata=true&versionType=branch&version=" + $VSOBranch +  
                "&api-version=" + $apiVersion
        Write-Log -Level 15 -Message "Connecting to VSO using URL: $VSOURL" -RunbookName Sync-AzureAutomationRunbooks
       
        $results = Invoke-RestMethod -Uri $VSOURL -Method Get -Headers $headers
    
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
            Write-Log -Level 15 -Message "Processing files in $folderObj[$i]" -RunbookName Sync-AzureAutomationRunbooks        
            $folderURL = "https://" + $VSOAccount + ".visualstudio.com/defaultcollection/_apis/git/" + 
                    $VSOProject + "/repositories/" + $VSORepository + "/items?scopepath=" + $folderObj[$i].path +  
                    "&recursionLevel=OneLevel&includecontentmetadata=true&versionType=branch&version=" + 
                    $VSOBranch + "&api-version=" + $apiVersion
                    
            $results = Invoke-RestMethod -Uri $folderURL -Method Get -Headers $headers
            
            foreach ($item in $results.value)
            {
                if (($item.gitObjectType -eq "blob") -and ($item.path -match $psExtension))
                {
                    $pathsplit = $item.path.Split("/")
                    $filename = $pathsplit[$pathsplit.Count - 1]
                    $tempPath = Join-Path -Path $env:SystemDrive -ChildPath "temp"
                    $outFile = Join-Path -Path $tempPath -ChildPath $filename
                    
                    Invoke-RestMethod -Uri $item.url -Method Get -Headers $headers -OutFile $outFile
            
                    InlineScript 
                    { 
                        #Get the runbook name
                        $fname = $Using:filename
                        $tempPathSplit = $fname.Split(".")
                        $runbookName = $tempPathSplit[0]
            
                        #Import ps1 files into Automation, create one if doesn't exist
                        Write-Verbose("Importing runbook $runbookName into Automation Account")
                        $rb = Get-AzureAutomationRunbook -AutomationAccountName $Using:AutomationAccount -ResourceGroupName $using:ResourceGroupName -Name $runbookName -ErrorAction  "SilentlyContinue"  
                        
                        #Remove the runbook,if existing and DeleteExistingRunbook is set to true
                        if ($rb -ne $null -and $Using:DeleteExistingRunbook -ieq "Yes")
                        {
                            Write-Verbose("Removing runbook $runbookName")
                            Remove-AzureAutomationRunbook -AutomationAccountName $rb.AutomationAccountName -ResourceGroupName $rb.ResourceGroupName -Name $rb.Name -Force 
                        }
                        $rb = Get-AzureAutomationRunbook -AutomationAccountName $Using:AutomationAccount -ResourceGroupName $using:ResourceGroupName -Name $runbookName -ErrorAction  "SilentlyContinue"  
                        if ($rb -eq $null)
                        {
                            #Import the runbook
                            Write-Verbose("Importing $runbookName from VSO-Git repository")
                            Import-AzureAutomationRunbook -Path $Using:outFile -Type PowerShellWorkflow -ResourceGroupName $Using:ResourceGroupName  -AutomationAccountName $Using:AutomationAccount 

                            #Publish the runbook
                            Write-Verbose("Publishing $runbookName")                                    
                            Publish-AzureAutomationRunbook -AutomationAccountName $Using:AutomationAccount -ResourceGroupName $Using:ResourceGroupName -Name $runbookName
                        }
                     }
                }
            }
        }
    }
    catch
    {
        $ErrorState = 2        
        Write-Verbose ($Error[0].Exception.tostring())
        Write-Verbose ($ErrorState)
        Throw($Error[0].Exception.tostring())
    }
    Write-Log -Level 15 -Message "`r`n*****************End workflow: Sync-AzureAutomationRunbooks*****************`r`n" -RunbookName Sync-AzureAutomationRunbooks        
}