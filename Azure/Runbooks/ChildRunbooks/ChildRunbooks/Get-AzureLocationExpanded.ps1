workflow Get-AzureLocationExpanded {

    param (
        
        [Parameter(Mandatory=$True)]
        [string] $Location
    )

    $correctlocation = "West US"
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