<#
.SYNOPSIS
    Installs a package like JRE, Apache, MySQL, PHP etc on an existing Linux (Ubuntu) VM.

.DESCRIPTION
    This runbook installs a package like JRE, Apache, MySQL, PHP etc on an existing Ubuntu VM. 
    It uses Custom Script Extension for Linux to achieve this. The custom script extension for Linux can execute a Linux shell script on the VM. 
    The code to install the package is written as a shell script and this script is stored in Azure Storage container. 
    The uri of the script is passed to the custom script extension. 
    Prerequisites:
        • An Ubuntu VM on Azure
        • Linux shell script copied to an Azure Storage container

.PARAMETER VMRGName
     Name of the Resource Group of the VM. 

.PARAMETER SourceVMName
     Name of the Linux VM. 

.PARAMETER Location
     Location of the VM.  Please ensure the correctness of alphabet case and spacing. The correct location casing and spelling examples:
        • "West US",
        • "East US",
        • "West Europe",
        • "East Asia",
        • "Southeast Asia"

.PARAMETER ExtensionName
    Name of the Extension. Any name can be provided, but if the custom script extension is already run once, 
    then this should be the same as previously provided in the first run

.PARAMETER fileName
    Name of the script.
 	Ex: "install_LAMPandJRE.sh"

.PARAMETER scriptParameters
    Input parameters for the script.
 	Ex: "Test@123"

.PARAMETER fileUri
    Uri of the script blob for the script.
    Ex: http://devteststorageaccount1.blob.core.windows.net/scripts/ install_LAMPandJRE.sh

.PARAMETER StorageRGName
     Name of the resource group of the storage account where the script is stored.

.PARAMETER storageAccountName
     Name of the storage account where the script is stored. 
    
.PARAMETER SubscriptionName
    String name of the target azure subscription. 

.PARAMETER OrgIDCredential
    String name of the orgid credential asset. This asset contains the credential for the user 
    that should have access to the target azure subscription.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Install-PackageOnLinuxVM
{
    param
    (
        $VMRGName,
        $VmName,
        $Location,
        $ExtensionName,
        $fileName,
        $scriptParameters,
        $fileUri,
        $StorageRGName,
        $storageAccountName,
        $SubscriptionName,
        $OrgIDCredential
    )

    if ($OrgIDCredential)
    {            
        Connect-Azure -OrgIDCredential $OrgIDCredential		
    }
    Select-AzureSubscription -SubscriptionName $SubscriptionName

    $storageAccountKey = (Get-AzureStorageAccountKey -ResourceGroupName $StorageRGName -Name $storageAccountName).Key1


    $ExtensionType = 'CustomScriptForLinux'
    $Publisher = 'Microsoft.OSTCExtensions'
    $Version = "1.2"

$PublicConf = @"
{
"fileUris": ["$fileUri"],
"commandToExecute": "sh $fileName $scriptParameters"
}
"@
$PrivateConf = @"
{
"storageAccountName": "$storageAccountName",
"storageAccountKey": "$storageAccountKey"
}
"@

    Remove-AzureVMExtension -ResourceGroupName $VMRGName -VMName $VmName -Name $ExtensionName -Force

    Set-AzureVMExtension -ResourceGroupName $VMRGName -VMName $VmName -Location $Location `
      -Name $ExtensionName -Publisher $Publisher `
      -ExtensionType $ExtensionType -TypeHandlerVersion $Version `
      -Settingstring $PublicConf -ProtectedSettingString $PrivateConf
}