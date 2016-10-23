<#
.SYNOPSIS
    Backs up the vhds and VM configuration of the input VM to a Backup storage container.

.DESCRIPTION
    This runbook backs up the vhds and VM configuration of the input VM to a Backup storage container. This accpets a BackupSuffix
    parameter which is used to name the backed up files and differentiate between multiple backed up files. 
    The vhds of the VM are snapshoted and copied to the Backup container folowing the naming convention "ResourceGroupName-VMName-vhdname-BackupSuffix.vhd".
    That includes both OS and data disks.
    The VM configuration is saved as a JSON file with naming convention "ResourceGroupName-VMName-BackupSuffix.json"
    The naming convention of the files 
    An ARM Template Parameters JSON file is generated with the VM configuration values and copied to backup container
    with naming convention "VMResourceGroupName-$VMName-ParamsTemplate-BackupSuffix.json". 
    
.PARAMETER SourceVMResourceGroupName
     String name of the resource group of the source VM. 

.PARAMETER SourceVMName
     String name of the source VM. 

.PARAMETER backupStorageAccountRG
     String name of the resource group of the backup storage account. 

.PARAMETER backupStorageAccount
     String name of the backup storage account. 

.PARAMETER backupContainer
     String name of the backup storage account container. 

.PARAMETER backupSuffix
    String unique name/label for the backup. This unique label will be appended to the backup, and will be used to identify the backup during restoring process.

.PARAMETER ParametersTemplateName
     String name of the template to be used for parameters to an Azure ARM template for new VM creation. This is a fixed generic template that needs to be present in the backup container. 
    
.PARAMETER SubscriptionName
    String name of the target azure subscription. 

.PARAMETER OrgIDCredential
    String name of the orgid credential asset. This asset contains the credential for the user 
    that should have access to the target azure subscription.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Backup-AzureVM
{
    param
    (
         [Parameter(Mandatory=$True)]
         $SourceVMResourceGroupName

        ,[Parameter(Mandatory=$True)]
         $SourceVMName    
             
        ,[Parameter(Mandatory=$True)]
         $backupStorageAccountRG 

        ,[Parameter(Mandatory=$True)]
         $backupStorageAccount

        ,[Parameter(Mandatory=$True)]
         $backupContainer

        ,[Parameter(Mandatory=$True)]
         $backupSuffix

        ,[Parameter(Mandatory=$True)]
         $ParametersTemplateName

        ,[Parameter(Mandatory=$True)]
         $SubscriptionName 

        ,[Parameter(Mandatory=$False)]
         $OrgIDCredential
    )
    <#Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Backup-AzureVM***************** `r`nInput Params: `r`nSourceVMResourceGroupName = $SourceVMResourceGroupName, `r`nSourceVMName = $SourceVMName, `r`nbackupStorageAccountRG = $backupStorageAccountRG, `r`nbackupStorageAccount = $backupStorageAccount, `r`nbackupContainer = $backupContainer, `r`nbackupSuffix = $backupSuffix, `r`nParametersTemplateName = $ParametersTemplateName, `r`nSubscriptionName = $SubscriptionName, `r`nOrgIDCredential = $OrgIDCredential`r`n" -RunbookName Backup-AzureVM        

    if ($OrgIDCredential)
    {            
        Write-Log -Level 15 -Message "Invoking command: Connect-Azure -OrgIDCredential $OrgIDCredential" -RunbookName Backup-AzureVM                  
        Connect-Azure -OrgIDCredential $OrgIDCredential	
    }

    Select-AzureSubscription -SubscriptionName $SubscriptionName
    $LocalFolderName = "Temp"
    $tempPath = Join-Path -Path $env:SystemDrive -ChildPath $LocalFolderName
    
    $exportedVMFileName = Get-TargetName -sourceName "$SourceVMResourceGroupName-$SourceVMName.json" -suffix $backupSuffix -ToAppendOrToRemove "Append" 
      
    $ParamsTemplateFileName = Get-TargetName -sourceName "$SourceVMResourceGroupName-$SourceVMName-ParamsTemplate.json" -suffix $backupSuffix -ToAppendOrToRemove "Append" 

    Write-Log -Level 15 -Message "Downloading file $ParametersTemplateName from Azure storage" -RunbookName Backup-AzureVM 
    Copy-FileFromAzStorage -StorageAccountRG $backupStorageAccountRG -StorageAccount $backupStorageAccount -FileName $ParametersTemplateName -StorageContainer $backupContainer -LocalFolderName $LocalFolderName -SubscriptionName $SubscriptionName

    $Disks  = InlineScript 
    {
        $vm =  Get-AzureVM -ResourceGroupName $Using:SourceVMResourceGroupName -Name $Using:SourceVMName
        ConvertTo-Json -InputObject $VM -Depth 200 | Out-File -FilePath "$using:tempPath\$Using:exportedVMFileName"

        $jsonParams = Get-Content -Raw -Path "$using:tempPath\$using:ParametersTemplateName" | ConvertFrom-Json 
        $jsonParams.parameters.location.value = $vm.Location
        $jsonParams.parameters.nicName.value = split-path  $vm.NetworkProfile.NetworkInterfaces[0].ReferenceUri -leaf
        $jsonParams.parameters.osType.value = $vm.StorageProfile.OSDisk.OperatingSystemType
        $jsonParams.parameters.vmName.value = $vm.Name
        $jsonParams.parameters.vmSize.value = $vm.HardwareProfile.VirtualMachineSize
        

        $SourceVMDiskUriArray = @($vm.StorageProfile.OSDisk.VirtualHardDisk.Uri)
        $SourceVMDiskUriArray += ($vm.StorageProfile.DataDisks| foreach { $_.VirtualHardDisk.uri})
        $OsDiskIndex = 0
        foreach ($uri in $SourceVMDiskUriArray)
        {
            $srcStorageAccount = ($uri -iReplace("htTp://","") -iReplace("hTtps://","")).Split('.')[0]
            $srcContainer = ($uri -iReplace("htTp://","") -iReplace("hTtps://","")).Split('/')[1]
            $srcVHDName = split-path $uri -Leaf

            $properties = @{'StorageAccount'= $srcStorageAccount;
                'StorageContainer'= $srcContainer;
                'SourceVHDName'= $srcVHDName;
                'StorageAccountRG' = $vm.ResourceGroupName
                 }
            $object = New-Object -TypeName PSObject -Property $properties
            $object
            if($OsDiskIndex -eq 0)
            {
                $jsonParams.parameters.newStorageAccountName.value = $srcStorageAccount
                $jsonParams.parameters.storageAccountContainerName.value = $srcContainer
                ConvertTo-Json -InputObject $jsonParams -Depth 200 | Out-File -FilePath "$using:tempPath\$using:ParamsTemplateFileName"                
            }
            $OsDiskIndex = $OsDiskIndex +1
        }
        
    }
    foreach ($Disk in $Disks)
    {
        $destVHDName = Get-TargetName -sourceName $disk.SourceVHDName -suffix $backupSuffix -ToAppendOrToRemove "Append"
        Write-Log -Level 15 -Message "Copying file $($Disk.SourceVHDName) as $destVHDName" -RunbookName Backup-AzureVM     
        Copy-VHD -SubscriptionName $SubscriptionName -copySnapShot $true -srcStorageAccountRG $Disk.StorageAccountRG -srcStorageAccount $Disk.StorageAccount -srcContainer $Disk.StorageContainer -srcVHDName $Disk.SourceVHDName -destStorageAccountRG $backupStorageAccountRG -destStorageAccount $backupStorageAccount -destContainer $backupContainer -destVHDName $destVHDName
    }
    
    Write-Log -Level 15 -Message "Uploading files $exportedVMFileName and $ParamsTemplateFileName to Azure storage" -RunbookName Backup-AzureVM     
        
    Copy-FileToAzStorage -StorageAccountRG $backupStorageAccountRG -StorageAccount $backupStorageAccount -FileName $exportedVMFileName -StorageContainer $backupContainer -LocalFolderName $LocalFolderName -SubscriptionName $SubscriptionName
    Copy-FileToAzStorage -StorageAccountRG $backupStorageAccountRG -StorageAccount $backupStorageAccount -FileName $ParamsTemplateFileName -StorageContainer $backupContainer -LocalFolderName $LocalFolderName -SubscriptionName $SubscriptionName

    Write-Log -Level 15 -Message "`r`n*****************End workflow: Backup-AzureVM*****************" -RunbookName Backup-AzureVM        
    #>
}