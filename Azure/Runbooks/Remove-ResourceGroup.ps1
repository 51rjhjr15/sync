<#
.SYNOPSIS 
    Removes an Azure Resource Group.

.DESCRIPTION
    Removes the given Azure Resource Group and all its resources.
    
    This runbook has a dependency on Connect-Azure runbook. The Connect-Azure runbook
    must be imported and published first for this runbook to work.
        
.PARAMETER OrgIDCredential
    Name of the credential asset containing the OrgId credentials name and password 
    that is the co-administrator of the subscription
    
.PARAMETER ResourceGroup
    Name of the resource group to be removed

.EXAMPLE
    Remove-ResourceGroup -OrgIDCredential "OrgId" -ResourceGroup "SqlDevTeam"

.NOTES
    LASTEDIT: Aug 28, 2015 
#>
workflow Remove-ResourceGroup
{
	param 
    (
       [Parameter(Mandatory=$True)]
       [string] $OrgIDCredential = "AutomationUser",

       [Parameter(Mandatory=$True)]
       [string] $ResourceGroup = "gopitestsvc"
    )

    try
    {
        # Connect to Azure 
        Connect-Azure -OrgIDCredential $OrgIDCredential
        
        if((Get-AzureResourceGroup -Name $ResourceGroup) -eq $null)
        {
            Write-Verbose "Resource Group '$ResourceGroup' does not exist"
            Throw "Resource Group '$ResourceGroup' does not exist"
        }
         # Get remaining VMs that are stopped and Start everything all at once
         Remove-AzureResourceGroup -Name $ResourceGroup -Force
		 "Resource Group removed"
    }
    catch
    {
        $ErrorState = 2        
        Write-Verbose ($Error[0].Exception.tostring())
        Write-Verbose ($ErrorState)
        Throw($Error[0].Exception.tostring())
    }
}