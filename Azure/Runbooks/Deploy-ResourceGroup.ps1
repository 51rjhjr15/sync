<#
.SYNOPSIS 
    Deploys azure resources to an azure resource group through ARM template

.DESCRIPTION
    Deploys azure resources to an azure resource group through ARM template. The resources to be deployed
    should be formatted in an ARM template and uploaded to an azure storage account. This runbook accepts
    the Uri to the uploaded ARM template and deploys the resources.
    If the resource group doesn't exist, it will be created automatically. Else it will be updated.
    
    This runbook has a dependency on Connect-Azure runbook. The Azure-Connect runbook must be published for this runbook to run correctly

.PARAMETER OrgIDCredential
    Name of the Azure credential asset that was created in the Automation service.
    This credential asset contains the user id & passowrd for the user who is having access to
    the azure subscription.
            
.PARAMETER ResourceGroupName
    Name of the resource group where the resources should be deployed to. 
    If the resource group doesn't exist, it will be created automatically. Else it will be updated.
    
.PARAMETER ResourceGroupLocation
    The location of the resource group

.PARAMETER DeploymentName
    The name for the current deployment

.PARAMETER TemplateFile
    The Uri of the ARM template file stored in azure storage account.

.PARAMETER TemplateParameterFile
    The Uri of the ARM template parameters file stored in azure storage account.
    
.EXAMPLE
    Deploy-ResourceGroup -OrgIDCredential "AutomationUser" -ResourceGroupName "WebAppDevTeam" -ResourceGroupLocation "West US" 
    -DeploymentName "InitialDeployment" -TemplateFile "https://gopinewstorageaccount.blob.core.windows.net/dsc/azuredeploy.json"
    -TemplateParameterFile "https://gopinewstorageaccount.blob.core.windows.net/dsc/azuredeploy.parameters.json"

.NOTES
    AUTHOR: MSGD
#>
workflow Deploy-ResourceGroup
{
	Param
    (
        [parameter(Mandatory=$true)] [String] $OrgIDCredential = "AutomationUser",
	    [parameter(Mandatory=$true)] [String] $ResourceGroupName = "VMDomainJoinRG",
	    [parameter(Mandatory=$true)] [String] $ResourceGroupLocation = "East Asia",
        [parameter(Mandatory=$true)] [String] $DeploymentName = "VMDomainDeployment",
        [parameter(Mandatory=$true)] [String] $TemplateFile = "https://gopinewstorageaccount.blob.core.windows.net/dsc/azuredeploy.json",
	    [parameter(Mandatory=$true)] [String] $TemplateParameterFile = "https://gopinewstorageaccount.blob.core.windows.net/dsc/azuredeploy.parameters.json"
    )
	
	$ErrorState = 0
	try
	{   
	    # Connect to Azure Subscription using the orgid credential
	    Connect-Azure -OrgIDCredential $OrgIDCredential 
	    
	    InlineScript
	    {
            #Convert the json template file into hashtable
			$templateparamspsobject = Invoke-RestMethod $Using:TemplateParameterFile
			$templateparams = @{}; 
			if($templateparamspsobject.parameters -eq $null){
			    $templateparamspsobject | Get-Member -MemberType *Property | % { $templateparams.($_.name) = $templateparamspsobject.($_.name).value; }        
			}
			else{        
			    $templateparamspsobject.parameters | Get-Member -MemberType *Property | % {$templateparams.($_.name) = $templateparamspsobject.parameters.($_.name).value; }
			}   
            Write-Verbose "Template parameter file read"
            
            #Create Resource Group if it doesn't exist already
            if((Get-AzureResourceGroup -Name $Using:ResourceGroupName) -eq $null)
            {
                Write-Verbose "Resource Group '$Using:ResourceGroupName' doesn't exist. Creating a new one"
                New-AzureResourceGroup -ResourceGroupName $Using:ResourceGroupName -Location $Using:ResourceGroupLocation -Force
                Write-Verbose "Resource Group '$Using:ResourceGroupName' Created"
            }

            #Deploy ARM Template into the resource group
	        $result = New-AzureResourceGroupDeployment -ResourceGroupName $Using:ResourceGroupName -Name $Using:DeploymentName -TemplateFile $Using:TemplateFile -TemplateParameterObject $templateparams
			Write-Output "Deployment State : $($result.ProvisioningState)"
			$result
	    }
	}
	catch
	{
        Write-Output ($Error[0].Exception.tostring())
        Throw($Error[0].Exception.tostring())
	}
}