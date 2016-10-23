<#
.SYNOPSIS 
    Syncs all json resource group templates in a VSO git repository to an Azure storage account.

.DESCRIPTION
    Syncs all json resource group templates in a VSO git repository to an Azure storage account. This runbook
    will recursively treat all sub directories within the VSOjsonFolderPath as dependent and publish these 
    first
    
    Requires a VSO Alternate Authentication Credential for connecting with VSO-Git repository, stored 
    in a Automation credential asset.
    
    The Azure-Connect runbook must be published for this runbook to run correctly
        
.PARAMETER VSOCredentialName
    Name of the credential asset containing the VSO Alternate Authentication Credential name 
    and password configured from VSO Profile dialog.
    
.PARAMETER VSOAccount
    Name of the account name for VSO Online.  Ex. https://accountname.visualstudio.com

.PARAMETER VSOProject
    Name of the VSO project that contains the repository     

.PARAMETER VSORepository
    Name of the repository that contains the runbook project

.PARAMETER VSOjsonFolderPath
    Project path to the root where the resource group templates are located.  Ex. /Project1/ProjectRoot
    where ProjectRoot contains the json files 

.PARAMETER AutomationAccount
    Name of the Automation Account where the runbooks should be synced to

.PARAMETER OrgIDCredential
    Name of the Azure credential asset that was created in the Automation service.
    This credential asset contains the user id & passowrd for the user who is having access to
    the azure subscription.    

.PARAMETER AzureSubscriptionName
    Name of the Azure subscription..
    
.PARAMETER VSOBranch
    Optional name of the Git branch to retrieve the runbooks from.  Defaults to "master"

.EXAMPLE
    Upload-VSOFilesToAzureStorage -VSOCredentialName "vsoCredentialAmit" -VSOAccount "managedservicesdev" 
    -VSOProject "ManagedServices" -VSOBranch "master" -VSORepository "ManagedServices" -VSOjsonFolderPath "/ResourceGroupTemplate" 
    -AzureSubscriptionName "Gopi-AzureSubscription" -OrgIDCredential "AutomationUser" -AzureStorageContainer "vso" 
    -AzureStorageAccount  "amitdevteststoacc" -StorageResourceGroupName "AmitDevTestRG" 


.NOTES
    AUTHOR: MSGD
#>
Workflow Upload-VSOFilesToAzureStorage
{
    param (
       [Parameter(Mandatory=$false)]
       [string] $VSOCredentialName ,

       [Parameter(Mandatory=$false)]
       [string] $VSOAccount,

       [Parameter(Mandatory=$false)]
       [string] $VSORepository ,

       [Parameter(Mandatory=$false)]
       [string] $VSOProject,

       [Parameter(Mandatory=$false)]
       [string] $VSOBranch,
       
       [Parameter(Mandatory=$false)]
       [string] $VSOjsonFolderPath,

       [Parameter(Mandatory=$false)]
       [string] $StorageResourceGroupName,
       
       [Parameter(Mandatory=$false)]
       [string] $AzureStorageContainer,
       
       [Parameter(Mandatory=$false)]
       [string] $AzureStorageAccount,

       [Parameter(Mandatory=$false)]
       [string] $AzureSubscriptionName,
       
       [Parameter(Mandatory=$false)]
       [string] $OrgIDCredential
    )
    
    Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Upload-VSOFilesToAzureStorage***************** `r`nInput Params: `r`nSourceVMResourceGroupName = $SourceVMResourceGroupName, `r`nSourceVMName = $SourceVMName, `r`nbackupStorageAccountRG = $backupStorageAccountRG, `r`nbackupStorageAccount = $backupStorageAccount, `r`nbackupContainer = $backupContainer, `r`nbackupSuffix = $backupSuffix, `r`nParametersTemplateName = $ParametersTemplateName, `r`nSubscriptionName = $SubscriptionName, `r`nOrgIDCredential = $OrgIDCredential`r`n" -RunbookName Upload-VSOFilesToAzureStorage
    $jsonExtension = "."
    $apiVersion = "1.0"
    $ErrorState = 0
    $ErrorMessage = "" 
    try
    {
        #Import and Publish the Connect-Azure runbook first     
        Connect-Azure -OrgIDCredential $OrgIDCredential   
        
        Select-AzureSubscription -SubscriptionName $AzureSubscriptionName | Write-Verbose
        Set-AzureSubscription -SubscriptionName $AzureSubscriptionName  -CurrentStorageAccountName $AzureStorageAccount | Write-Verbose
    
        #Getting Credentail asset for VSO alternate authentication credentail
        $VSOCred = Get-AutomationPSCredential -Name $VSOCredentialName
        if ($VSOCred -eq $null)
        {
            Write-Log -Level 15 -Message "Could not retrieve '$VSOCredentialName' credential asset. Check that you created this asset in the Automation service." -RunbookName Upload-VSOFilesToAzureStorage -IsError 
            throw "Could not retrieve '$VSOCredentialName' credential asset. Check that you created this asset in the Automation service."
        }
        $VSOAuthUserName = $VSOCred.UserName
        $VSOAuthPassword = $VSOCred.GetNetworkCredential().Password
      
        $StorageAccount = Get-AzureStorageAccount -ResourceGroupName $StorageResourceGroupName -Name $AzureStorageAccount
        if($StorageAccount -eq $null )
        {
            Write-Log -Level 15 -Message "Storage Account $AzureStorageAccount does not exist" -RunbookName Upload-VSOFilesToAzureStorage -IsError
            Throw("Storage Account $AzureStorageAccount does not exist")
        }
        
        InlineScript{
                $StorageAccountKey = Get-AzureStorageAccountKey -ResourceGroupName $Using:StorageAccount.ResourceGroupName -Name $Using:StorageAccount.Name
                $StorageContext = New-AzureStorageContext -StorageAccountName $Using:StorageAccount.Name -StorageAccountKey $StorageAccountKey.Key1 

                if((Get-AzureStorageContainer -Name $Using:AzureStorageContainer -Context $StorageContext) -eq $null )
                {
                    Write-Verbose("Storage container $Using:AzureStorageContainer does not exist")
                    Throw("Storage container $Using:AzureStorageContainer does not exist")
                }
           } 
        
        
        #Creating authorization header using 
        $basicAuth = ("{0}:{1}" -f $VSOAuthUserName,$VSOAuthPassword)
        $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
        $basicAuth = [System.Convert]::ToBase64String($basicAuth)
        $headers = @{Authorization=("Basic {0}" -f $basicAuth)}
    
        #ex. "https://gkeong.visualstudio.com/defaultcollection/_apis/git/automation-git-test2-proj/repositories/automation-git-test2-proj/items?scopepath=/Project1/Project1/&recursionlevel=full&includecontentmetadata=true&versionType=branch&version=production&api-version=1.0-preview"
        $VSOURL = "https://" + $VSOAccount + ".visualstudio.com/defaultcollection/_apis/git/" + 
                $VSOProject + "/repositories/" + $VSORepository + "/items?scopepath=" + $VSOjsonFolderPath +  
                "&recursionlevel=full&includecontentmetadata=true&versionType=branch&version=" + $VSOBranch +  
                "&api-version=" + $apiVersion
                
        Write-Log -Level 15 -Message "Connecting to VSO using URL: $VSOURL" -RunbookName Upload-VSOFilesToAzureStorage
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
            Write-Log -Level 15 -Message "Processing files in $folderObj[$i]" -RunbookName Upload-VSOFilesToAzureStorage        
            $folderURL = "https://" + $VSOAccount + ".visualstudio.com/defaultcollection/_apis/git/" + 
                    $VSOProject + "/repositories/" + $VSORepository + "/items?scopepath=" + $folderObj[$i].path +  
                    "&recursionLevel=OneLevel&includecontentmetadata=true&versionType=branch&version=" + 
                    $VSOBranch + "&api-version=" + $apiVersion
                    
            $results = Invoke-RestMethod -Uri $folderURL -Method Get -Headers $headers
            
            foreach ($item in $results.value)
            {
                if (($item.gitObjectType -eq "blob") -and ($item.path -match $jsonExtension))
                {
                    $pathsplit = $item.path.Split("/")
                    $filename = $pathsplit[$pathsplit.Count - 1]
                    $tempPath = Join-Path -Path $env:SystemDrive -ChildPath "temp"
                    $outFile = Join-Path -Path $tempPath -ChildPath $filename
                    
                    Invoke-RestMethod -Uri $item.url -Method Get -Headers $headers -OutFile $outFile
            
                      InlineScript{                           
                            $fname = $Using:outFile      
                            $StorageAccountKey = Get-AzureStorageAccountKey -ResourceGroupName $Using:StorageAccount.ResourceGroupName -Name $Using:StorageAccount.Name
                            $StorageContext = New-AzureStorageContext -StorageAccountName $Using:StorageAccount.Name -StorageAccountKey $StorageAccountKey.Key1 
                              
                            #Import ps1 files into Automation, create one if doesn't exist
                            Write-Verbose("Importing Template file into Storage Account")
                            Get-Item –Path $fname | Set-AzureStorageBlobContent -Container $Using:AzureStorageContainer -Context $StorageContext -Force | Write-Verbose                   
                    }
                }
            }
        }
    }
    catch
    {
        $ErrorState = 2        
        Write-Log -Level 5 -Message "An error occurred with following details: $_" -RunbookName Upload-VSOFilesToAzureStorage -IsError $true
        Throw($Error[0].Exception.tostring())
    }
    Write-Log -Level 15 -Message "`r`n*****************End workflow: Upload-VSOFilesToAzureStorage *****************" -RunbookName Upload-VSOFilesToAzureStorage      
}