param (
    [string]$PullServerWebDirectory = "C:\DSCPullServer",
    [string]$PullServerSubDirectory = "bin",
    [string]$IISAppPoolName = "DSCPullServer",
    [string]$IISAppPoolDotNetVersion = "v4.0",
    [string]$IISAppName = "DSCPullServer1",
    [string]$Webport = "8090"
 )

<#$PullServerWebDirectory = "C:\DSCPullServer"
$PullServerSubDirectory = "bin"
$IISAppPoolName = "DSCPullServer"
$IISAppPoolDotNetVersion = "v4.0"
$IISAppName = "DSCPullServer1"
$Webport = "8090"#>
    

$Action = 'Installing Pull Server...';
$Trace += "Beginning  action '$Action' `r`n" 
$Trace += "Parameters:`r`n"    
$Trace += "`r`n"

$PowershellRootFeatureName = "PowershellRoot" 
$Powershell4FeatureName = "Powershell" 
$PowershellISEFeatureName = "Powershell-ISE" 
$IISWindowsFeature = "Web-Server"
$NET35WindowsFeature = "NET-Framework-Features"
$NET45WindowsFeature = "NET-Framework-45-Features"
$ODataWindowsFeature = "ManagementOData"
$DSCWindowsFeatureName = "DSC-Service"

$Trace += "Installing Windows features `r`n"
    #try
    #{
$Trace += "Installing Windows features `r`n"
Install-WindowsFeature -Name $PowershellRootFeatureName -IncludeManagementTools -IncludeAllSubFeature | Out-Null
Install-WindowsFeature -Name $Powershell4FeatureName -IncludeManagementTools -IncludeAllSubFeature| Out-Null
Install-WindowsFeature -Name $PowershellISEFeatureName -IncludeManagementTools -IncludeAllSubFeature| Out-Null
Install-WindowsFeature -Name $IISWindowsFeature -IncludeManagementTools -IncludeAllSubFeature| Out-Null
Install-WindowsFeature -Name $NET35WindowsFeature -IncludeManagementTools -IncludeAllSubFeature| Out-Null
Install-WindowsFeature -Name $NET45WindowsFeature -IncludeManagementTools -IncludeAllSubFeature| Out-Null
Install-WindowsFeature -Name $ODataWindowsFeature -IncludeManagementTools -IncludeAllSubFeature| Out-Null
Install-WindowsFeature -Name $DSCWindowsFeatureName -IncludeManagementTools -IncludeAllSubFeature| Out-Null

$Trace += "Coping Web application files `r`n"
New-item -Path $PullServerWebDirectory -ItemType Directory -Force | Out-Null
New-item -Path $($PullServerWebDirectory + "\" + $PullServerSubDirectory) -ItemType Directory -Force | Out-Null

Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\Global.asax" -Destination "$PullServerWebDirectory\Global.asax" | Out-Null
Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.mof" -Destination "$PullServerWebDirectory\PSDSCPullServer.mof"| Out-Null
Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.svc" -Destination "$PullServerWebDirectory\PSDSCPullServer.svc"| Out-Null
Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.xml" -Destination "$PullServerWebDirectory\PSDSCPullServer.xml"| Out-Null
Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.config" -Destination "$PullServerWebDirectory\web.config"| Out-Null

Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\Microsoft.Powershell.DesiredStateConfiguration.Service.dll" -Destination "$($PullServerWebDirectory + "\" + $PullServerSubDirectory + "\Microsoft.Powershell.DesiredStateConfiguration.Service.dll")" | Out-Null

Import-Module WebAdministration | Out-Null


#navigate to the app pools root
cd IIS:\AppPools\ | out-null

#check if the app pool exists
if (!(Test-Path $IISAppPoolName -pathType container))
{
    $Trace += "Creating application pool.. `r`n"
    $appPool = New-Item $IISAppPoolName | Out-Null
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $IISAppPoolDotNetVersion | out-null
}

#navigate to the sites root
cd IIS:\Sites\ | out-null

            
if (Test-Path $IISAppName -pathType container)
{
    $Trace += "Web application already exists.. `r`n"
}
else
{
    $Trace += "Creating Web application.. `r`n"
    $IISApp = New-Item IIS:\Sites\$IISAppName -bindings @{protocol="http";bindingInformation=":$($Webport):"} -physicalPath $PullServerWebDirectory | out-null
    $IISApp | Set-ItemProperty -Name "applicationPool" -Value $IISAppPoolName | Out-Null
}
            
$Trace += "Setting Authentication modules.. `r`n"
$appcmd = "$env:windir\system32\inetsrv\appcmd.exe" 

& $appCmd set AppPool $appPool.name /processModel.identityType:LocalSystem /SilentMode| Out-Null
& $appCmd unlock config -section:access /SilentMode| Out-Null
& $appCmd unlock config -section:anonymousAuthentication /SilentMode| Out-Null
& $appCmd unlock config -section:basicAuthentication /SilentMode| Out-Null
& $appCmd unlock config -section:windowsAuthentication /SilentMode| Out-Null


Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\Devices.mdb" -Destination "$env:programfiles\WindowsPowerShell\DscService\Devices.mdb" | Out-Null

$Trace += "Updating Web.config appsetting values `r`n"
$xml = [XML](Get-Content "$PullServerWebDirectory\web.config")                                                                                   
$RootDoc = $xml.get_DocumentElement()                                                                                                                          
$subnode = $xml.CreateElement("add")  
$subnode.SetAttribute("key", "dbprovider")                                                                                                                    
$subnode.SetAttribute("value", "System.Data.OleDb")                                                                                                                    
$RootDoc.appSettings.AppendChild($subnode) | Out-Null
  
$subnode = $xml.CreateElement("add")  
$subnode.SetAttribute("key", "dbconnectionstr")                                                                                                                    
$subnode.SetAttribute("value", "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=C:\Program Files\WindowsPowerShell\DscService\Devices.mdb;")                                                                                                                    
$RootDoc.appSettings.AppendChild($subnode) | Out-Null

$subnode = $xml.CreateElement("add")  
$subnode.SetAttribute("key", "ConfigurationPath")                                                                                                                    
$subnode.SetAttribute("value", "C:\Program Files\WindowsPowerShell\DscService\Configuration")                                                                                                                    
$RootDoc.appSettings.AppendChild($subnode) | Out-Null

$subnode = $xml.CreateElement("add")  
$subnode.SetAttribute("key", "ModulePath")                                                                                                                    
$subnode.SetAttribute("value", "C:\Program Files\WindowsPowerShell\DscService\Modules")                                                                                                                    
$RootDoc.appSettings.AppendChild($subnode) | Out-Null
                                                                                                                      
$xml.Save("$PullServerWebDirectory\web.config")  | Out-Null
# }
# catch
# {
#     $ErrorState = 2
#     $ErrorMessage = "Importing of the VMM module failed"
#     $Trace += "Importing of the VMM module failed  `r`n"
#     Throw "Error: Importing of the VMM module failed ."        
# }
       
      

$ErrorMessage = ''
$ErrorState = 0   #Return Success
$Trace += "Completed remote action '$Action'... `r`n"


