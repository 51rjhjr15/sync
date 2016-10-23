#http://techibee.com
[cmdletbinding()]
param()

$Sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites
$obj = @()
foreach ($Site in $Sites) {

 $obj += New-Object -Type PSObject -Property (
  @{
   "SiteName"  = $site.Name
   "SubNets" = $site.Subnets -Join ";"
   "Servers" = $Site.Servers -Join ";"
  }
 )
}
$obj | Export-Csv 'sites.csv' -NoType