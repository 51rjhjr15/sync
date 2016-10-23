<#
.SYNOPSIS
    Restores or Clones the already backed up VMs by the runbook Backup-AzureVM.

.DESCRIPTION
    This runbook restores or clones the already backed up VMs by the runbook Backup-AzureVM. 
    For restore Mode: CloneToASeperateStorage = "No" 
        The runbook identifies the backup by the unique backupSuffix, and copies the associated VHDs back to the VMs original container, deletes the VM and recreates it with the values of the Parameter template and VM backup config JSON file.
    For clone Mode: CloneToASeperateStorage = "Yes" 
        Before running this runbook, the JSON Parameter file in the backup container with naming convention "VMResourceGroupName-$VMName-ParamsTemplate-BackupSuffix.json" needs to be updated with new values of parameters like
        storage account, container, NIC ( These must be precreated manually) and can be saved back in the backup container with any name. This name must be passed to the parameter ParametersTemplateName of this runbook. 
        The runbook identifies the backup by the unique backupSuffix, and copies the associated VHDs to the container mentioned in the parameters JSON file, and creates another VM with the values of the Parameter template and VM backup config JSON file.
    
.PARAMETER SourceVMResourceGroupName
     String name of the resource group of the VM that needs to be restored. 

.PARAMETER SourceVMName
     String name of the VM that needs to be restored. 

.PARAMETER backupStorageAccountRG
     String name of the resource group of the backup storage account. 

.PARAMETER backupStorageAccount
     String name of the backup storage account. 

.PARAMETER backupContainer
     String name of the backup storage account container. 

.PARAMETER backupSuffix
    String unique name/label of the backup to be restored. This unique label will be used to identify the particular backup amoung the various backups available for the VM.

.PARAMETER NewVMTemplateName
    String name of the parameters JSON file.
    This is required only in the case of cloning the VM to a different location. In this case the parameters JSON file is edited with the new values of storage, nic etc, and is provided via this parameter. 
          
.PARAMETER CloneToASeperateStorage
     String "Yes" or "No"
    CloneToASeperateStorage = "No" is used for restore Mode: 
        The runbook identifies the backup by the unique backupSuffix, and copies the associated VHDs back to the VMs original container, deletes the VM and recreates it with the values of the Parameter template and VM backup config JSON file.
    CloneToASeperateStorage = "Yes" is used for clone Mode: 
        Before running this runbook, the JSON Parameter file in the backup container with naming convention "VMResourceGroupName-$VMName-ParamsTemplate-BackupSuffix.json" needs to be updated with new values of parameters like
        storage account, container, NIC ( These must be precreated manually) and can be saved back in the backup container with any name. This name must be passed to the parameter ParametersTemplateName of this runbook. 
        The runbook identifies the backup by the unique backupSuffix, and copies the associated VHDs to the container mentioned in the parameters JSON file, and creates another VM with the values of the Parameter template and VM backup config JSON file.

.PARAMETER ParametersTemplateName
       Name of the parameters JSON file updated with the properties of the new VM.
    This is required only in the case of cloning the VM to a different location

.PARAMETER DestVMResourceGroupName
    Name of the resource group where the new VM will be created under
        
    
        ,[Parameter(Mandatory=$False)]
         [string]$ParametersTemplateName

        ,[Parameter(Mandatory=$False)]
         [string]$DestVMResourceGroupName
.PARAMETER SubscriptionName
    String name of the target azure subscription. 

.PARAMETER OrgIDCredential
    String name of the orgid credential asset. This asset contains the credential for the user 
    that should have access to the target azure subscription.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Restore-AzureVM
{
    param
    (
         [Parameter(Mandatory=$True)]
         [string]$SubscriptionName 

        ,[Parameter(Mandatory=$True)]
         [string]$SourceVMResourceGroupName 
            
        ,[Parameter(Mandatory=$True)]
         [string]$SourceVMName 

        ,[Parameter(Mandatory=$True)]
         [string]$backupStorageAccountRG 

        ,[Parameter(Mandatory=$True)]
         [string]$backupStorageAccount 

        ,[Parameter(Mandatory=$True)]
         [string]$backupContainer 

        ,[Parameter(Mandatory=$True)]
         [string]$backupSuffix 

        ,[Parameter(Mandatory=$True)]
         [string]$NewVMTemplateName 

        ,[Parameter(Mandatory=$True)]
         [string]$CloneToASeperateStorage 
             
        ,[Parameter(Mandatory=$False)]
         [string]$ParametersTemplateName

        ,[Parameter(Mandatory=$False)]
         [string]$DestVMResourceGroupName
         ,[Parameter(Mandatory=$False)]
         [string]$OrgIDCredential 
    )
    Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Restore-AzureVM***************** `r`nInput Params: `r`nSourceVMResourceGroupName = $SourceVMResourceGroupName, `r`nSourceVMName = $SourceVMName, `r`nbackupStorageAccountRG = $backupStorageAccountRG, `r`nbackupStorageAccount = $backupStorageAccount, `r`nbackupContainer = $backupContainer, `r`nbackupSuffix = $backupSuffix, `r`nParametersTemplateName = $ParametersTemplateName, `r`nSubscriptionName = $SubscriptionName, `r`nOrgIDCredential = $OrgIDCredential`r`n" -RunbookName Restore-AzureVM        

    if ($OrgIDCredential)
    {            
        Write-Log -Level 15 -Message "Invoking command: Connect-Azure -OrgIDCredential $OrgIDCredential" -RunbookName Restore-AzureVM                  
        Connect-Azure -OrgIDCredential $OrgIDCredential	
    }

    Select-AzureSubscription -SubscriptionName $SubscriptionName
    $LocalFolderName = "Temp"
    $tempPath = Join-Path -Path $env:SystemDrive -ChildPath $LocalFolderName
    $exportedVMFileName = Get-TargetName -sourceName "$SourceVMResourceGroupName-$SourceVMName.json" -suffix $backupSuffix -ToAppendOrToRemove "Append"    
    $ParamsTemplateFileName = Get-TargetName -sourceName "$SourceVMResourceGroupName-$SourceVMName-ParamsTemplate.json" -suffix $backupSuffix -ToAppendOrToRemove "Append" 
    # Use the param template file if it is provided as param which takes priority (cloning) over the backed up param template (restore).
    if ( $ParametersTemplateName)
    {
        $ParamsTemplateFileName = $ParametersTemplateName
    }
    $Diskjson = @"
{
    "diskSizeGB": 2,
    "lun": 0,
    "createOption": "Attach",
    "name": "diskname",
    "vhd": {
        "uri": "[concat('http://',parameters('newStorageAccountName'),'.blob.core.windows.net/',parameters('storageAccountContainerName'),'/','REPLACE_DATAVHDBLOBNAME')]"
    }
}
"@
    $DatadiskObjs = @()
       
        
    # Download the json files
    Write-Log -Level 15 -Message "Download the json files $ParamsTemplateFileName , $exportedVMFileName and $NewVMTemplateName" -RunbookName Restore-AzureVM        

    Copy-FileFromAzStorage -StorageAccountRG $backupStorageAccountRG -StorageAccount $backupStorageAccount -FileName $ParamsTemplateFileName -StorageContainer $backupContainer -LocalFolderName $LocalFolderName -SubscriptionName $SubscriptionName
    Copy-FileFromAzStorage -StorageAccountRG $backupStorageAccountRG -StorageAccount $backupStorageAccount -FileName $exportedVMFileName -StorageContainer $backupContainer -LocalFolderName $LocalFolderName -SubscriptionName $SubscriptionName
    Copy-FileFromAzStorage -StorageAccountRG $backupStorageAccountRG -StorageAccount $backupStorageAccount -FileName $NewVMTemplateName -StorageContainer $backupContainer -LocalFolderName $LocalFolderName -SubscriptionName $SubscriptionName
    

    $jsonParams = Get-Content -Raw -Path "$tempPath\$ParamsTemplateFileName" | ConvertFrom-Json
    $exportedVM = Get-Content -Raw -Path "$tempPath\$exportedVMFileName" | ConvertFrom-Json 
    
    $exportedVMOSDiskURI = $exportedVM.StorageProfile.OSDisk.VirtualHardDisk.Uri
    $DestStorageAccount = $jsonParams.parameters.newStorageAccountName.value
    $DestContainer = $jsonParams.parameters.storageAccountContainerName.value
    if (! $DestVMResourceGroupName)
    {
       $DestVMResourceGroupName = $SourceVMResourceGroupName
    }

    
    $SourceVMDiskUriArray = @($exportedVMOSDiskURI)
    $SourceVMDiskUriArray += ($exportedVM.StorageProfile.DataDisks| foreach { 
        $diskObj = ConvertFrom-Json($Diskjson)
        $diskObj.createOption = "Attach"
        $diskObj.diskSizeGB = $_.DiskSizeGB
        $diskObj.lun = $_.Lun
        $diskObj.name = $_.Name
        $vhdblobname = Split-Path -Path ($_.VirtualHardDisk.Uri) -Leaf
        $diskObj.vhd.uri = $diskObj.vhd.uri.Replace("REPLACE_DATAVHDBLOBNAME", $vhdblobname)
        $DatadiskObjs += $diskObj
    $_.VirtualHardDisk.uri
    })

    # Update the VM Template with data disks
    InlineScript
    {
        $VMTemplate = Get-Content -Raw -Path "$Using:tempPath\$Using:NewVMTemplateName" | ConvertFrom-Json
        $exportedVMOSDiskBlobName = Split-Path -Path $Using:exportedVMOSDiskURI -Leaf
        $templateOSDiskURI = $VMTemplate.resources[0].properties.storageProfile.osDisk.vhd.uri -ireplace "REPLACE_OSVHDBLOBNAME",$exportedVMOSDiskBlobName
        $VMTemplate.resources[0].properties.storageProfile.osDisk.vhd.uri = $templateOSDiskURI
        $VMTemplate.resources[0].properties.storageProfile.dataDisks = $Using:DatadiskObjs
        ConvertTo-Json -InputObject $VMTemplate -Depth 200 | Out-File "$Using:tempPath\$Using:NewVMTemplateName"
    }

    
    if ($CloneToASeperateStorage -ine "Yes")
    {
        Write-Log -Level 15 -Message "Deleting the VM $SourceVMName as $CloneToASeperateStorage is NOT set to 'Yes'" -RunbookName Restore-AzureVM  
        Remove-AzureVM -ResourceGroupName $SourceVMResourceGroupName -Name $SourceVMName -Force
    }
    foreach ($uri in $SourceVMDiskUriArray)
    {
        $destVHDName = split-path $uri -Leaf
        $srcVHDName =  Get-TargetName -sourceName $destVHDName -suffix $backupSuffix -ToAppendOrToRemove "Append"
       
        Write-Log -Level 15 -Message "Copying the VHD $srcVHDName from backup container $backupContainer to as $destVHDName in the target container $DestContainer." -RunbookName Restore-AzureVM 
        Copy-VHD -SubscriptionName $SubscriptionName -copySnapShot $false -srcStorageAccountRG $backupStorageAccountRG -srcStorageAccount $backupStorageAccount -srcContainer $backupContainer -srcVHDName $srcVHDName -destStorageAccountRG $DestVMResourceGroupName -destStorageAccount $DestStorageAccount -destContainer $DestContainer -destVHDName $destVHDName 
    }

    Write-Log -Level 15 -Message "Creating a new deployment for the VM." -RunbookName Restore-AzureVM         
    New-AzureResourceGroupDeployment -Name ($exportedVMFileName -iReplace(".json","")) -ResourceGroupName $DestVMResourceGroupName -TemplateParameterFile (Join-Path -Path $tempPath -ChildPath $ParamsTemplateFileName) -TemplateFile (Join-Path -Path $tempPath -ChildPath $NewVMTemplateName)
    Write-Log -Level 15 -Message "`r`n*****************End workflow: Restore-AzureVM*****************" -RunbookName Restore-AzureVM        
}