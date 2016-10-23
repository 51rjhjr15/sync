<#
.SYNOPSIS 
    Starts all VMs in an azure resource group

.DESCRIPTION
    Starts all VMs in the given azure resource group.
    
    This runbook has a dependency on Connect-Azure runbook. The Connect-Azure runbook must be published for this runbook to run correctly

.PARAMETER OrgIDCredential
    Name of the Azure credential asset that was created in the Automation service.
    This credential asset contains the user id & passowrd for the user who is having access to
    the azure subscription.
            
.PARAMETER ResourceGroupName
    Name of the resource group that contains the VM
        
.EXAMPLE
    Start-AzureVMs -OrgIDCredential "AutomationUser" -ResourceGroupName "WebAppDevTeam"

.NOTES
    AUTHOR: MSGD
#>
workflow Start-AzureVMs
{   
    param 
    (
       [Parameter(Mandatory=$True)]
       [string] $OrgIDCredential = "AutomationUser",

       [Parameter(Mandatory=$True)]
       [string] $ResourceGroupName = "DevTestRG"
    )
        	
    $ErrorState = 0
    $ErrorMessage = ""     
    try
    {
    	# Connect to Azure Subscription using the orgid credential
	    Connect-Azure -OrgIDCredential $OrgIDCredential 
    
        if((Get-AzureResourceGroup -Name $ResourceGroupName) -eq $null)
        {
            Write-Verbose "Resource Group '$ResourceGroupName' does not exist"
            Throw "Resource Group '$ResourceGroupName' does not exist"
        }
        
        # Get all VMs in the resource group
        $VMs = Get-AzureVM -ResourceGroupName $ResourceGroupName
        
        foreach -parallel ($vm in $VMs)
        {   
            Write-Verbose "Starting VM : $($vm.Name)"
             $result = Start-AzureVM -Name $vm.Name -ResourceGroupName $ResourceGroupName
			 "VM Start Status : $($result.Status)"
             if(($result.Status) -ne 'Succeeded')
             {       
				 $result
             }
             $result
        }
    }
    catch
    {
        $ErrorState = 2        
        Write-Verbose ($Error[0].Exception.tostring())
        Write-Verbose ($ErrorState)
        Throw($Error[0].Exception.tostring())
    }
    
}