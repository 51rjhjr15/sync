<#
.SYNOPSIS 
    Configures an azure VM as a DSC Pull server.

.DESCRIPTION
    Configures an azure VM as a DSC Pull server. 
    
    This runbook uses a powershell script SetupDSCPullServer.ps1 to configure DSC pull server. This script file should be uploaded
    to an azure storage container, the details of which should be passed as parameters.

    This runbook has a dependency on Connect-Azure and Run-ScriptInAzureVM runbooks. Both these runbooks must be published 
    for this runbook to run correctly

.PARAMETER OrgIDCredential
    Name of the Azure credential asset that was created in the Automation service.
    This credential asset contains the user id & passowrd for the user who is having access to
    the azure subscription.
            
.PARAMETER VMResourceGroup
    Name of the resource group that contains the VM to be configured

.PARAMETER VMName
    Name of the azure VM to be configured
    
.PARAMETER DSCInstallerResourceGroup
    Name of the resource group that contains the storage account where the script file SetupDSCPullServer.ps1 is uploaded

.PARAMETER DSCInstallerStorageAccount
    Name of the storage account where the script file SetupDSCPullServer.ps1 is uploaded

.PARAMETER DSCInstallerStorageContainer
    Name of the storage container where the script file SetupDSCPullServer.ps1 is uploaded
    
.PARAMETER DSCInstallerFile
    The script file that configures the DSC pull server. "SetupDSCPullServer.ps1" is the script file name.

.EXAMPLE
    Configure-DSCPullServer -ORGIDCredential "AutomationUser" -VMResourceGroup "WebAppDevTeam" -VMName "DSC-Pullserver" 
    -DSCInstallerResourceGroup "RepositoryRG" -DSCInstallerStorageAccount "RepositoryStorage" -DSCInstallerStorageContainer "DevTestFiles" 
    -DSCInstallerFile "SetupDSCPullServer.ps1"

.NOTES
    AUTHOR: MSGD
#>

workflow Configure-DSCPullServer {

    param (
        
        [Parameter(Mandatory=$True)]
        [string] $ORGIDCredential = "AutomationUser",
        
        [parameter(Mandatory=$true)]
        [String]
        $VMResourceGroup = "VirtualMachineRG",
        
        [parameter(Mandatory=$true)]
        [String]
        $VMName = "DSCVMachine",  
        
        [parameter(Mandatory=$true)]
        [String]
        $DSCInstallerResourceGroup="VirtualMachineRG",

        [parameter(Mandatory=$true)]
        [String]
        $DSCInstallerStorageAccount="dscstorageaccount34",

        [parameter(Mandatory=$true)]
        [String]
        $DSCInstallerStorageContainer="dsccontainer",

        [parameter(Mandatory=$true)]
        [String]
        $DSCInstallerFile="SetupDSCPullServer.ps1"

    )
    
    # Run the SetupDSCPullServer script inside the VM to setup the pull server
    Run-ScriptInAzureVM -ORGIDCredential $ORGIDCredential -VMResourceGroup $VMResourceGroup -VMName $VMName `
        -StorageResourceGroup $DSCInstallerResourceGroup -StorageAccount $DSCInstallerStorageAccount -StorageContainer $DSCInstallerStorageContainer `
        -ScriptFiles $DSCInstallerFile -StartupFile $DSCInstallerFile

}