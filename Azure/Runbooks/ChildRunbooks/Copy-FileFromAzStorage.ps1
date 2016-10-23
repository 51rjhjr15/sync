<#
.SYNOPSIS
    Copies file from azure storage account to local environment.

.DESCRIPTION
    This runbook copies file from azure storage account to local environment. 
    
.PARAMETER StorageAccountRG
     String name of the resource group containing storage account inside which the file is located 
     
.PARAMETER StorageAccount
     String name of the existing storage account inside which the file is located 

.PARAMETER StorageContainer
    String name of the azure storage container inside which the file is located
     
.PARAMETER FileName
    String name of the blob in the storage account to be downloaded.

.PARAMETER LocalFolderName
    String name of the local folder where the file should be saved
       
.PARAMETER SubscriptionName
    String name of the target azure subscription. 

.PARAMETER OrgIDCredential
    String name of the orgid credential asset. This asset contains the credential for the user 
    that should have access to the target azure subscription.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Copy-FileFromAzStorage
{
    [OutputType([object])]
     param 
     (

        [parameter(Mandatory=$true)] [String] $StorageAccountRG,
        [parameter(Mandatory=$true)] [String] $StorageAccount,
        [parameter(Mandatory=$true)] [String] $FileName,
        [parameter(Mandatory=$true)] [String] $StorageContainer,	
        [Parameter(Mandatory=$True)] [string] $LocalFolderName,                
        [parameter(Mandatory=$True)] [String] $SubscriptionName,
	    [parameter(Mandatory=$false)] [String] $OrgIDCredential
     )     
    
    $VerbosePreference = "Continue"
    $LogException = $True

    try
    {   
        Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Copy-FileFromAzStorage*****************`r`nInput params: `r`nStorageAccountRG = $StorageAccountRG, StorageAccount = $StorageAccount, `r`nFileName = $FileName, `r`nStorageContainer = $StorageContainer, `r`nLocalFolderName = $LocalFolderName, `r`nSubscriptionName = $SubscriptionName, `r`nOrgIDCredential = $OrgIDCredential `r`n" -RunbookName Copy-FileFromAzStorage        
        
        if ($OrgIDCredential)
        {            
            Write-Log -Level 15 -Message "Invoking command: Connect-Azure -OrgIDCredential $OrgIDCredential" -RunbookName Copy-FileFromAzStorage          
            Connect-Azure -OrgIDCredential $OrgIDCredential
        }
        Select-AzureSubscription -SubscriptionName $SubscriptionName -Verbose

        $tempPath = Join-Path -Path $env:SystemDrive -ChildPath $LocalFolderName
        $outFile = Join-Path -Path $tempPath -ChildPath $FileName

        # Getting the file from Azure Storage and saving it in local environment 
        Write-Log -Level 15 -Message "Getting the file from Azure Storage and saving it in local environment" -RunbookName Copy-FileFromAzStorage 
        InlineScript
        {  
            $StorageKey = (Get-AzureStorageAccountKey -ResourceGroupName $Using:StorageAccountRG -Name $Using:StorageAccount).Key1
            $Context = New-AzureStorageContext -StorageAccountName $Using:StorageAccount -StorageAccountKey $StorageKey
            Get-AzureStorageBlobContent -Container $Using:StorageContainer -Blob $Using:FileName -Destination $Using:outFile -Context $Context -Force -Verbose
        } 
        if(Test-Path $outFile)
        {
            Write-Log -Level 10 -Message "File $FileName copied successfully to '$outFile'" -RunbookName Copy-FileFromAzStorage
        }
        else
        {
            Write-Log -Level 5 -Message "Error in coping file $FileName to '$outFile'." -RunbookName Copy-FileFromAzStorage -IsError $True
        }
    }
    Catch
    {       
        if($LogException)
        {
            Write-Log -Level 5 -Message "An error occurred with following details: $_" -RunbookName Copy-FileFromAzStorage -IsError $true
        } 
    }
    finally
    {
        Write-Log -Level 15 -Message "*****************End workflow: Copy-FileFromAzStorage*****************`r`n" -RunbookName Copy-FileFromAzStorage
    } 
}