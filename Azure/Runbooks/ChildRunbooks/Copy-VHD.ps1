<#
.SYNOPSIS
    Copies vhd blob from a storage container to another across same or different storage accounts.

.DESCRIPTION
    This runbook copies vhd blob from a storage container to another across same or different storage accounts. 
    
.PARAMETER srcStorageAccountRG
     String name of the resource group of the source storage account. 

.PARAMETER srcStorageAccount
     String name of the source storage account. 

.PARAMETER srcContainer
     String name of the source storage account container. 

.PARAMETER srcVHDName
    String name of the source vhd blob to be copied.
    
.PARAMETER destStorageAccountRG
     String name of the resource group of the destination storage account. 

.PARAMETER destStorageAccount
     String name of the destination storage account. 

.PARAMETER destContainer
     String name of the destination storage account container. 

.PARAMETER destVHDName
    String name of the destination vhd blob.
    
.PARAMETER copySnapShot
    String "Yes" if a snapshot of the vhd is to be copied.
           "No"  if the vhd is directly copied without snapshotting.
    
.PARAMETER SubscriptionName
    String name of the target azure subscription. 

.PARAMETER OrgIDCredential
    String name of the orgid credential asset. This asset contains the credential for the user 
    that should have access to the target azure subscription.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Copy-VHD
{
    param
    (
        
        [Parameter(Mandatory=$True)]
        [string]$srcStorageAccountRG ,
        [Parameter(Mandatory=$True)]
        [string]$srcStorageAccount , 
        [Parameter(Mandatory=$True)]
        [string]$srcContainer ,
        [Parameter(Mandatory=$True)]
        [string]$srcVHDName , 
        [Parameter(Mandatory=$True)]
        [string]$destStorageAccountRG, 
        [Parameter(Mandatory=$True)]
        [string]$destStorageAccount,
        [Parameter(Mandatory=$True)]
        [string]$destContainer,
        [Parameter(Mandatory=$True)]
        [string]$destVHDName,
        [Parameter(Mandatory=$True)]
        [string] $copySnapShot,
        [Parameter(Mandatory=$True)]
        [string] $SubscriptionName,
        [Parameter(Mandatory=$False)]
       	[string] $OrgIDCredential
            
    )
    Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Copy-VHD***************** `r`nInput Params: `r`nsrcStorageAccountRG = $srcStorageAccountRG, `r`nsrcStorageAccount = $srcStorageAccount, `r`nsrcContainer = $srcContainer, `r`nsrcVHDName = $srcVHDName, `r`ndestStorageAccountRG = $destStorageAccountRG, `r`ndestStorageAccount = $destStorageAccount, `r`ndestContainer = $destContainer, `r`ndestVHDName = $destVHDName, `r`ncopySnapShot = $copySnapShot, `r`nSubscriptionName = $SubscriptionName, `r`nOrgIDCredential = $OrgIDCredential`r`n" -RunbookName Copy-VHD        

    if ($OrgIDCredential)
    {            
        Write-Log -Level 15 -Message "Invoking command: Connect-Azure -OrgIDCredential $OrgIDCredential" -RunbookName Copy-VHD                  
        Connect-Azure -OrgIDCredential $OrgIDCredential		
    }

	Select-AzureSubscription -SubscriptionName $SubscriptionName
    InlineScript
    {

        $srcStorageKey = (Get-AzureStorageAccountKey -ResourceGroupName $Using:srcStorageAccountRG -Name $Using:srcStorageAccount).Key1
        $srcContext = New-AzureStorageContext -StorageAccountName $Using:srcStorageAccount -StorageAccountKey $srcStorageKey
   
        $destStorageKey = (Get-AzureStorageAccountKey -ResourceGroupName $Using:destStorageAccountRG -Name $Using:destStorageAccount).Key1
        $destContext = New-AzureStorageContext -StorageAccountName $Using:destStorageAccount -StorageAccountKey $destStorageKey
   
        
        $blob= Get-AzureStorageBlob -Context $srcContext -Container $Using:srcContainer -Blob $Using:srcVHDName
        if($Using:copySnapShot -ieq "Yes")
        {
            $snap = $blob.ICloudBlob.CreateSnapshot()  
        }
        else
        {
            $snap = $blob.ICloudBlob
        }

        $targetBlob = Start-AzureStorageBlobCopy -ICloudBlob $snap -DestContainer $Using:destContainer -DestBlob $Using:destVHDName -Context $destContext -Force
            
        ### Retrieve the current status of the copy operation ###
        $status = $targetBlob | Get-AzureStorageBlobCopyState 
            
        ### Loop until complete ###                                    
        While($status.Status -ieq "Pending"){
            $status = $targetBlob | Get-AzureStorageBlobCopyState
            Start-Sleep 10
        }
            
        if($Using:copySnapShot -ieq "Yes")
        {
            Remove-AzureStorageBlob -ICloudBlob $snap -Context $srcContext
        }
   }

    Write-Log -Level 15 -Message "*****************End workflow: Copy-VHD*****************`r`n" -RunbookName Copy-VHD
}