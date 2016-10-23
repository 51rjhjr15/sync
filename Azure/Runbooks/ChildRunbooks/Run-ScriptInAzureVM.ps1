<#
.SYNOPSIS 
    Configure a already proviiosned VM as DSC PUll Server .
    
.DESCRIPTION
    This runbook configures a server as DSC Pull Server.
    New-AzureVM runbook should be published and executed to create a VM before running this runbook.
       
.NOTES
    LASTEDIT: March 30 , 2015 
#>

workflow Run-ScriptInAzureVM {

    param (
        
        [Parameter(Mandatory=$True)]
        [string] $ORGIDCredential = "AutomationUser",

        [parameter(Mandatory=$true)]
        [String]
        $VMResourceGroup = "VirtualMachineRG4",
        
        [parameter(Mandatory=$true)]
        [String]
        $VMName = "DSCVMachine4",

        [parameter(Mandatory=$true)]
        [String]
        $StorageResourceGroup="VirtualMachineRG",

        [parameter(Mandatory=$true)]
        [String]
        $StorageAccount="dscstorageacc",

        [parameter(Mandatory=$true)]
        [String]
        $StorageContainer="dsccontainer",
		
		[parameter(Mandatory=$true)]
        [String]
        $ScriptFiles="SetupDSCPullServer.ps1",

        [parameter(Mandatory=$true)]
        [String]
        $StartupFile="SetupDSCPullServer.ps1",
		
        [String]
        $ScriptArguments

    )

    try
    {
        # Get credentials to Azure VM
        Connect-Azure -ORGIDCredential $ORGIDCredential
       
        InlineScript 
        {
            $VMResourceGroup = $Using:VMResourceGroup
            $VMName = $Using:VMName
            
            $ErrorState = 2
            $ErrorMessage = ""
            $Trace = "Trace Begins: "

            Write-Verbose "Resource Group : $VMResourceGroup, VM : $VMName"
            
            function Get-Loc($Location)
            {
                $correctlocation = ""
                switch -CaseSensitive ($Location) 
                {
                    "centralus" { $correctlocation = "Central US" }
                    "eastasia" { $correctlocation = "East Asia" }
                    "eastus" { $correctlocation = "East US" }
                    "eastus2" { $correctlocation = "East US2" }
                    "japaneast" { $correctlocation = "Japan East" }
                    "japanwest" { $correctlocation = "Japan West" }
                    "northcentralus" { $correctlocation = "North Central US" }
                    "northeurope" { $correctlocation = "North Europe" }
                    "southcentralus" { $correctlocation = "South Central US" }
                    "southeastasia" { $correctlocation = "Southeast Asia" }
                    "westeurope" { $correctlocation = "West Europe" }
                    "westus" { $correctlocation = "West US" }
                    default { $correctlocation = "West US" } 
                }
                return $correctlocation
            }

            $vm = Get-AzureVM -ResourceGroupName $VMResourceGroup -Name $VMName
            Write-Verbose "VM Location : $($vm.Location)"
            $VMLocation = Get-Loc -Location $vm.Location
            Write-Verbose "VM Location retrieved from Get-AzureLocationExpanded : $VMLocation"

            Write-Verbose "Getting Storage Account key"
            $key = Get-AzureStorageAccountKey -ResourceGroupName $using:StorageResourceGroup -Name $using:StorageAccount

            Write-Verbose "Removing any existing custom script extension for this VM"
            $removeresult = Remove-AzureVMCustomScriptExtension -ResourceGroupName $Using:VMResourceGroup -VMName $Using:VMName -Name 'SetupDSC' -Force
			
            $result = $null
            if($using:ScriptArguments.Length -lt 1)
            {
                Write-Verbose "No arguments for script file"
                $result = Set-AzureVMCustomScriptExtension -ResourceGroupName $using:VMResourceGroup -VMName $using:VMName -Name 'SetupDSC' `
                        -TypeHandlerVersion '1.1' -StorageAccountName $using:StorageAccount `
                        -ContainerName $using:StorageContainer -FileName $using:ScriptFiles `
                        -StorageAccountKey $key.Key1 -Run $using:StartupFile -Location $VMLocation
                
            }
            else
            {
                $result = Set-AzureVMCustomScriptExtension -ResourceGroupName $using:VMResourceGroup -VMName $using:VMName -Name 'SetupDSC' `
                        -TypeHandlerVersion '1.1' -StorageAccountName $using:StorageAccount `
                        -ContainerName $using:StorageContainer -FileName $using:ScriptFiles `
                        -StorageAccountKey $key.Key1 -Run $using:StartupFile -Argument $using:ScriptArguments -Location $VMLocation
               
            }
			Write-Verbose "Status : $($result.Status)"
			
            if($result.Status -ne 'Failed'){
                $result.Error.Message
            }
			"Result Here:"
			$result
        }
    }
    catch
    {
		$message = $_.Exception.Message
        Write-Output "Error:"  
		Write-Output $_.Exception.Message  
		Write-Output $message    
    } 

}