<#
.SYNOPSIS 
    Copies files from VSO git repository to an Azure VM.

.DESCRIPTION
    Copies files from VSO git repository folder path to an Azure VM. 
    All files and subfolders are copied to the given path in the azure VM.
    
    This runbook uses a powershell script Get-FilesFromVSO.ps1 to copy the files from VSO git. This script file should be uploaded
    to an azure storage container, the details of which should be passed as parameters.

    Requires a VSO Alternate Authentication Credential for connecting with VSO-Git repository, stored 
    in a Automation credential asset.
    
    The Azure-Connect runbook must be published for this runbook to run correctly

.PARAMETER VSOCredentialName
    Name of the credential asset containing the VSO Alternate Authentication Credential name 
    and password configured from VSO Profile dialog.

.PARAMETER VSORepository
    Name of the repository that contains the runbook project

.PARAMETER VSOProject
    Name of the VSO project that contains the repository 

.PARAMETER VSOBranch
    Optional name of the Git branch to retrieve the runbooks from.  Defaults to "master"

.PARAMETER VSOFolderPath
    Path to the folder from where the files should be copied from.  Ex. /Project1/ProjectRoot

.PARAMETER DownloadFolderPath
    The path in the VM to which the files are to be copied to

.PARAMETER OrgIDCredential
    Name of the Azure credential asset that was created in the Automation service.
    This credential asset contains the user id & passowrd for the user who is having access to
    the azure subscription. 

.PARAMETER ResourceGroup
    Name of the resource group that contains the VM

.PARAMETER VMName
    Name of the azure VM

.PARAMETER StorageAccountResourceGroup
    Name of the resource group that contains the storage account where the script file Get-FilesFromVSO.ps1 is uploaded

.PARAMETER StorageAccount
    Name of the storage account where the script file Get-FilesFromVSO.ps1 is uploaded

.PARAMETER StorageContainer
    Name of the storage container where the script file Get-FilesFromVSO.ps1 is uploaded
    
.PARAMETER ScriptFile
    The script file that configures the DSC pull server."Get-FilesFromVSO.ps1" is the script file name.

.PARAMETER SubscriptionName
    Name of the Azure subscription.
    
.EXAMPLE
    Copy-VSOFilesToAzureVM -VSOAccount "managedservicesdev" -VSORepository "automationlib" -VSOProject "ManagedServices" -VSOBranch "master" `
    -VSOFolderPath "/ProjectFiles" -DownloadFolderPath "C:\VSOFiles" -VSOCredentialName "vsoCredentialAmit" -ORGIDCredential "AutomationUser" `
    -ResourceGroup "WebAppDevTeam" -VMName "WebFE2" -StorageAccountResourceGroup "CommonRG" -StorageAccount "ProjectFilesStorage" `
    -StorageContainer "ProjectFiles" -ScriptFile "Get-FilesFromVSO.ps1" -SubscriptionName "AzureSubscription"

.NOTES
    AUTHOR: MSGD
#>
workflow Copy-VSOFilesToAzureVM {

    param (
        [Parameter(Mandatory=$true)]
        [string] $VSOAccount,

        [Parameter(Mandatory=$true)]
        [string] $VSORepository ,

        [Parameter(Mandatory=$true)]
        [string] $VSOProject,

        [Parameter(Mandatory=$true)]
        [string] $VSOBranch,
       
        [Parameter(Mandatory=$true)]
        [string] $VSOFolderPath,
       
        [Parameter(Mandatory=$true)]
        [string] $DownloadFolderPath,

        [Parameter(Mandatory=$true)]
        [string] $VSOCredentialName ,
        
        [Parameter(Mandatory=$True)]
        [string] $ORGIDCredential ,

        [parameter(Mandatory=$true)]
        [String] $ResourceGroup,
        
        [parameter(Mandatory=$true)]
        [String] $VMName,
        
        [parameter(Mandatory=$true)]
        [String] $StorageAccountResourceGroup,

        [parameter(Mandatory=$true)]
        [String] $StorageAccount ,

        [parameter(Mandatory=$true)]
        [String] $StorageContainer ,

        [parameter(Mandatory=$true)]
        [String] $ScriptFile,

        [parameter(Mandatory=$true)]
        [String] $SubscriptionName
    )
    $VerbosePreference = "Continue"
    
    try
    {
       #Import and Publish the Connect-Azure runbook first     
        if ($OrgIDCredential)
        {            
            Connect-Azure -OrgIDCredential $OrgIDCredential
        }
        Select-AzureSubscription -SubscriptionName $SubscriptionName -Verbose

        #Getting Credentail asset for VSO alternate authentication credentail
        $VSOCred = Get-AutomationPSCredential -Name $VSOCredentialName
        if ($VSOCred -eq $null)
        {
            throw "Could not retrieve '$VSOCredentialName' credential asset. Check that you created this asset in the Automation service."
        }
        $VSOAuthUserName = $VSOCred.UserName
        $VSOAuthPassword = $VSOCred.GetNetworkCredential().Password
        
        $ScriptFileParams = " -VSOAccount $VSOAccount -VSORepository  $VSORepository  -VSOProject $VSOProject -VSOBranch $VSOBranch -VSOFolderPath $VSOFolderPath -VSOAuthUserName $VSOAuthUserName -VSOAuthPassword $VSOAuthPassword -DownloadFolderPath $DownloadFolderPath"

        #Get All VMs in the resource group
        $VM = Get-AzureVM -ResourceGroupName $ResourceGroup -Name $VMName
        
            Write-Verbose "Running download VSO files script on vm : $($vm.Name)" 
            Run-ScriptInAzureVM -ORGIDCredential $ORGIDCredential -VMResourceGroup $ResourceGroup -VMName $vm.Name `
                -StorageResourceGroup $StorageAccountResourceGroup -StorageAccount $StorageAccount -StorageContainer $StorageContainer `
                -ScriptFiles $ScriptFile -StartupFile $ScriptFile -ScriptArguments $ScriptFileParams
        
        Write-Verbose "Script execution complete."
    }
    catch
    {
        Write-Error "Error: $_"   
    } 
    
}
