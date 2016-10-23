workflow Connect-Azure 
{ 
    Param 
    (    
        [Parameter(Mandatory=$true)] 
        [String] 
        $OrgIDCredential        
    ) 
     
    # Get the Azure credential asset that is stored in the Auotmation service based on the name that was passed into the runbook  
    $Cred = Get-AutomationPSCredential -Name $OrgIDCredential
	"Credentials found : $OrgIDCredential"

    if ($Cred -eq $null) 
    { 
        throw "Could not retrieve '$OrgIDCredential' credential asset. Check that you created this first in the Automation service." 
    } 
    
	# Connect to Azure
	Add-AzureAccount -Credential $Cred
    "Connected to Azure"
}