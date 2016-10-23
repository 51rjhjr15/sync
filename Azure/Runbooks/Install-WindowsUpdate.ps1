<#
.SYNOPSIS 
    Installs windows update to all VMs in an azure resource group.

.DESCRIPTION
    Installs windows update to all VMs in an azure resource group.
    
    This runbook uses a powershell script InstallWindowsUpdateLocally.ps1 to insall the updates. This script file should be uploaded
    to an azure storage container, the details of which should be passed as parameters.

    The powershell script InstallWindowsUpdateLocally.ps1 uses the windows update powershell module provided by 
    'Michael Gajda' here https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc

    This runbook has a dependency on Connect-Azure and Run-ScriptInAzureVM runbooks. Both these runbooks must be published 
    for this runbook to run correctly

.PARAMETER OrgIDCredential
    Name of the Azure credential asset that was created in the Automation service.
    This credential asset contains the user id & passowrd for the user who is having access to the azure subscription.
            
.PARAMETER ResourceGroup
    Name of the resource group that contains the VMs to be updated

.PARAMETER StorageAccountResourceGroup
    Name of the resource group that contains the storage account where the script file SetupDSCPullServer.ps1 is uploaded

.PARAMETER StorageAccount
    Name of the storage account where the script file InstallWindowsUpdateLocally.ps1 is uploaded

.PARAMETER StorageContainer
    Name of the storage container where the script file InstallWindowsUpdateLocally.ps1 is uploaded
    
.PARAMETER InstallerFile
    The script file that installs the windows update. "InstallWindowsUpdateLocally.ps1" is the script file name.

.PARAMETER WindowsUpdateModuleFileUri
    "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/43/PSWindowsUpdate.zip"

.EXAMPLE
    Install-WindowsUpdate -ORGIDCredential "AutomationUser" -ResourceGroup "WebAppDevTeam" -StorageAccountResourceGroup "RepositoryRG" 
    -StorageAccount "RepositoryStorage" -StorageContainer "CommonFiles" -InstallerFile "InstallWindowsUpdateLocally.ps1" 
    -WindowsUpdateModuleFileUri "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/43/PSWindowsUpdate.zip" -AutoReboot "Yes"

.NOTES
    AUTHOR: MSGD
#>

workflow Install-WindowsUpdate {

    param (
        
        [Parameter(Mandatory=$True)]
        [string] $ORGIDCredential = "AutomationUser",

        [parameter(Mandatory=$true)]
        [String]
        $ResourceGroup = "RemotePowershellRG",
        
        [parameter(Mandatory=$true)]
        [String]
        $StorageAccountResourceGroup = "TestARMResourceGroup",

        [parameter(Mandatory=$true)]
        [String]
        $StorageAccount = "gopinewstorageaccount",

        [parameter(Mandatory=$true)]
        [String]
        $StorageContainer = "dsc",

        [parameter(Mandatory=$true)]
        [String]
        $InstallerFile="InstallWindowsUpdateLocally.ps1",

        [parameter(Mandatory=$true)]
        [String]
        $WindowsUpdateModuleFileUri = "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/43/PSWindowsUpdate.zip",

        [parameter(Mandatory=$false)]
        [String]
        $AutoReboot = "yes"
    )

    
    try
    {
        # Get credentials to Azure VM
        Connect-Azure -ORGIDCredential $ORGIDCredential

        #Get All VMs in the resource group
        $VMs = Get-AzureVM -ResourceGroupName $ResourceGroup
      
        #Install windows update on all VMs
        foreach -parallel ($vm in $VMs)
        {       
            Write-Verbose "Installing windows update on vm : $($vm.Name)" 
            
            Run-ScriptInAzureVM -ORGIDCredential $ORGIDCredential -VMResourceGroup $ResourceGroup -VMName $vm.Name `
                -StorageResourceGroup $StorageAccountResourceGroup -StorageAccount $StorageAccount -StorageContainer $StorageContainer `
                -ScriptFiles $InstallerFile -StartupFile $InstallerFile -ScriptArguments "$WindowsUpdateModuleFileUri $AutoReboot"
        }
        Write-Output "Script execution complete. Windows update installed on all VMs"
    }
    catch
    {
        $ErrorState = 2         
    } 

}