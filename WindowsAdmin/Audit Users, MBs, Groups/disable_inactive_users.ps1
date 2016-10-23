#=====================================================================================================#
#    Copyright 2011 Robert Stacks
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#=====================================================================================================#
# Author: David Beasley
# Updated: Robert Stacks
# Original Script URL: http://vnucleus.com/2011/07/use-powershell-to-auto-disable-inactive-active-directory-accounts/
# Updated Script URL: https://randomtechminutia.wordpress.com/2014/07/09/powershell-script-to-disable-inactive-users-v3/
# Date: 7/26/2011
# Updated: 7/9/2014
# Verson: 0.6
#
# Purpose:
# Disable Inactive Active Directory Accounts
#
# Update Notes:
# 7/9/2014 - Robert Stacks
# - Added remote domain functionality
# - Added user option to enable/disable moving of disabled accounts
# - Updated the Report with a CSS Style Sheet and overall improved formatting
# - Added Creation Date column
# - Added DN Column which shows DN prior to move to disabled OU so if someone needs to re-enable an account they can move it back to the correct OU
#
#=====================================================================================================#
 
#===========================#
#User Adjustable Variables  #
#===========================#
 
#Account with rights to remotely log into domain
$AdminAcct = 'domain.local\AdminAcct'
$Adminpwd = 'password'
 
#Domain to Log into
$domain = 'domain.local'
 
#Company Name - Used for Report
$CompanyName = 'Company Name'
 
# Query Options #
$searchRoot = "domain.local/" # Where to begin your recursive search - If you use top-level (e.g. "domain.local/") make sure to have a trailing slash, otherwise do not use a slash (e.g. "domain.local/Users")
$inactiveDays = 90 # Integer for number of days of inactivity (e.q. 90)
$timeSinceCreation = 30 # Integer for number of "grace" days since the account was created (to prevent disabling of brand new accounts)
$sizeLimit = 0 # How many users do you want returned. 0 = unlimited. Without setting this the default is 1000
 
# Action Options #
$MovedisabledAccount = 0 # 0 = disabled or 1=enabled Defines if the script will move a disabled account
$disabledOU = "domain.local/Users/Disabled" # Define where disabled accounts are stored (e.g. "domain.local/Users/Disabled")
 
# Email Settings #
$emailAlerts = 1 # Turn e-mail alerts on or off. 0 = off 1 = On
$fromAddr = "ADInactiveAccounts@domain.COM" # Enter the FROM address for the e-mail alert
$toAddr = "sysadmins@domain.com" # Enter the TO address for the e-mail alert
$smtpsrv = "mail.domain.com" # Enter the FQDN or IP of a SMTP relay
 
# Enable Script #
$enableAction = 0 # Change to 0 if you want to "whatif" this script - It will bypass the actual account disabling (turn e-mail alerts on!)
 
#===========================#
#Main Script                #
#===========================#
 
$date = Get-Date -Format d
 
# Format html report with CSS
$htmlReport = @"
<style type='text/css'>
.heading {
color:white;
font-size:14.0pt;
font-weight:700;
font-family:Verdana, sans-serif;
text-align:left;
vertical-align:middle;
height:20.0pt;
width:416pt;
background:#1975D1
 
}
.colnames {
color:white;
font-size:10.0pt;
font-weight:700;
font-family:Tahoma, sans-serif;
text-align:center;
vertical-align:middle;
border:.5pt solid white;
background:#3385FF;
}
.textcolor1 {
color:windowtext;
font-size:9.0pt;
font-family:Arial;
text-align:center;
vertical-align:middle;
border:1pt solid windowtext;
background:#C1D0E6;
}
.textcolor2 {
color:windowtext;
font-size:9.0pt;
font-family:Arial;
text-align:center;
vertical-align:middle;
border:1pt solid windowtext;
background:white;
}
</style>
<table border=0 cellpadding=4 cellspacing=1 width=auto
style='border-collapse:collapse;table-layout:auto;width:auto'>
<tr style='height:15.0pt'>
<th rowspan=3 colspan=5 height=40 width=auto class="heading">
<center>$CompanyName</center>
<center>Report:$($inactiveUsers.Count) User Accounts Disabled Due to Inactivity</center>
<center>Date: <i> $date </i> Domain: <i> $domain </i></center>
</th>
</tr>
<tr></tr>
<tr>
<th class="colnames">Name</th>
<th class="colnames">Account</th>
<th class="colnames">Creation Date</th>
<th class="colnames">Last Login</th>
<th class="colnames">DN</th>
</tr>
"@
 
Add-PSSnapin "Quest.ActiveRoles.ADManagement"
 
#Set User account to be used to log into cross site domain without AD Trust
$username = $AdminAcct
$password = ConvertTo-SecureString $Adminpwd -AsPlainText -Force
$livecrd = New-Object System.Management.Automation.PSCredential $username, $password
 
#Connect to the specific domain
Connect-QADService -Service $domain -Credential $livecrd
 
#Cutoff Date
$creationCutoff = (Get-Date).AddDays(-$timeSinceCreation)
 
#Get list of inactive user accounts
$inactiveUsers = @(Get-QADUser -SearchRoot $searchRoot -Enabled -NotLoggedOnFor $inactiveDays -CreatedBefore $creationCutoff -SizeLimit $sizeLimit | Select-Object Name,SamAccountName,CreationDate,LastLogonTimeStamp,Description,DN | Sort-Object Name)
 
# Counter for color in table
$i = 0
 
# Generate table
do {
if($i % 2)
{$htmlReport += "<tr class='textcolor1'><td>$($inactiveUsers[$i].Name)</td><td>$($inactiveUsers[$i].SamAccountName)</td><td>$($inactiveUsers[$i].CreationDate)</td><td>$($inactiveUsers[$i].LastLogonTimestamp)</td><td>$($inactiveUsers[$i].DN)</td></tr>";$i++}
else
{$htmlReport += "<tr class='textcolor2'><td>$($inactiveUsers[$i].Name)</td><td>$($inactiveUsers[$i].SamAccountName)</td><td>$($inactiveUsers[$i].CreationDate)</td><td>$($inactiveUsers[$i].LastLogonTimestamp)</td><td>$($inactiveUsers[$i].DN)</td></tr>";$i++}
}
while ($inactiveUsers[$i] -ne $null)
 
# Finish create of Table
if($MovedisabledAccount -eq 1){
$htmlReport += @"
<th colspan=5 height=40 width=auto class="footer">
 <center>Note: Disabled Computer Objects moved to this OU: <i>$disabledOU</i></center></th>
</tr>
</table></center>
"@
}
else{
$htmlReport += @"
<th colspan=5 height=40 width=auto class="footer">
 <center>Note: Disabled Computer Objects where not moved during this operation.</center></th>
</tr>
</table></center>
"@
}
 
# Disable Accounts #
if ($enableAction -eq 1 -and $inactiveUsers -ne $null){
 foreach($user in $inactiveUsers){
 Set-QADUser $user.SamAccountName -Description "Account Disabled on $date for Inactivity - $($user.Description)" | Disable-QADUser
  #Move Disabled Accounts to Disabled OU
  if ($MovedisabledAccount -ne 0){
   Move-QADObject $user -NewParentContainer $disabledOU
   }
 }
}
 
### Email Alerts ###
if ($emailAlerts -eq 1 -and $inactiveUsers -ne $null){
 
Send-MailMessage -To $toAddr -From $fromAddr -Subject "AutoDisable Report for $($domain): $($inactiveUsers.Count) User Accounts Disabled on $date" -Body "$htmlReport" -SmtpServer $smtpsrv -BodyAsHtml
}
 
#Disconnect from AD Cleanly
Disconnect-QADService
 
exit