<#
.SYNOPSIS
    Copies file from local environment to azure storage account.

.DESCRIPTION
    This runbook copies file from local environment to azure storage account. 
    
.PARAMETER StorageAccountRG
     String name of the resource group containing storage account. 

.PARAMETER StorageAccount
     String name of the existing storage account inside which the file is to be copied. 

.PARAMETER StorageContainer
    String name of the azure storage container inside which the file is to be copied.
    
.PARAMETER FileName
    String name of the file blob
    
.PARAMETER LocalFolderName
    String name of the local folder from where the file should be copied to Azure Storage.
       
.PARAMETER SubscriptionName
    String name of the target azure subscription. 

.PARAMETER OrgIDCredential
    String name of the orgid credential asset. This asset contains the credential for the user 
    that should have access to the target azure subscription.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Copy-FileToAzStorage
{
    [OutputType([object])]
     param 
     (
        [parameter(Mandatory=$true)] [String] $StorageAccountRG ,
        [parameter(Mandatory=$true)] [String] $StorageAccount,
        [parameter(Mandatory=$true)] [String] $FileName,
        [parameter(Mandatory=$true)] [String] $StorageContainer,	
        [Parameter(Mandatory=$True)] [string] $LocalFolderName,                
        [parameter(Mandatory=$false)] [String] $SubscriptionName,
	    [parameter(Mandatory=$false)] [String] $OrgIDCredential
		
     )     
    
    $VerbosePreference = "Continue"
    $LogException = $True

    try
    {   
        Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Copy-FileToAzStorage*****************`r`nInput params: `r`nStorageAccountRG = $StorageAccountRG, StorageAccount = $StorageAccount, `r`nFileName = $FileName, `r`nStorageContainer = $StorageContainer, `r`nLocalFolderName = $LocalFolderName, `r`nSubscriptionName = $SubscriptionName, `r`nOrgIDCredential = $OrgIDCredential`r`n" -RunbookName Copy-FileToAzStorage        
        
        if ($OrgIDCredential)
        {            
            Write-Log -Level 15 -Message "Invoking command: Connect-Azure -OrgIDCredential $OrgIDCredential" -RunbookName Copy-FileToAzStorage          
            Connect-Azure -OrgIDCredential $OrgIDCredential
        }
        
        $tempPath = Join-Path -Path $env:SystemDrive -ChildPath $LocalFolderName
        $outFile = Join-Path -Path $tempPath -ChildPath $FileName
        
        Write-Log -Level 15 -Message "Validating File"  -RunbookName Copy-FileToAzStorage
        if(!(Test-Path $outFile))
        {
            Write-Log -Level 5 -Message "File $FileName does not exist" -RunbookName Copy-FileToAzStorage -IsError $True
            $LogException = $false
            Throw("File $FileName does not exist")
        }       
        
        Select-AzureSubscription -SubscriptionName $SubscriptionName
        $isCopySuccessful = InlineScript
        {   
            $StorageKey = (Get-AzureStorageAccountKey -ResourceGroupName $Using:StorageAccountRG -Name $Using:StorageAccount).Key1
            $Context = New-AzureStorageContext -StorageAccountName $Using:StorageAccount -StorageAccountKey $StorageKey
            Set-AzureStorageBlobContent -File $Using:outFile -Container $Using:StorageContainer -Blob $Using:FileName -Context $Context -Force -Verbose
            $output = (Get-AzureStorageBlob -Container $Using:StorageContainer -Blob $Using:FileName -Context $Context).Name -ieq $Using:FileName
            $output
        }    
        if ($isCopySuccessful)
        {
            Write-Log -Level 10 -Message "File $FileName uploaded successfully to container '$StorageContainer'" -RunbookName Copy-FileToAzStorage
        }
        else
        {
            Write-Log -Level 5 -Message "Error in uploading file to container $StorageContainer ." -RunbookName Copy-FileToAzStorage -IsError $True
        }
        
    }
    Catch
    {       
        if($LogException)
        {
            Write-Log -Level 5 -Message "An error occurred with following details: $_" -RunbookName Copy-FileToAzStorage -IsError $true
        } 
    }
    finally
    {
        Write-Log -Level 15 -Message "*****************End workflow: Copy-FileToAzStorage*****************`r`n" -RunbookName Copy-FileToAzStorage
    } 
}