<#
.SYNOPSIS
    Tests a website by sending an HTTP request and validating the Http Response code from the server.

.DESCRIPTION
    This runbook tests a website by sending an HTTP request and validating the Http Response code from the server. 
    In order to test if Apache Server is up and running, even if no website is deployed, just mention the server name or IP Address in the url, 
    which will provide a response from the default page.
    The runbook returns true if the Http Response Code is 200, and returns false in all other cases.

.PARAMETER URL
     URL to be tested. In case apache server needs to be tested, url would be “http://<serverName or IP>”. 

.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Test-URL
{
    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $URL
    )
    $VerbosePreference = "Continue"
    try
    {
        # Create the request.
        $HTTP_Request = [System.Net.WebRequest]::Create($URL)

        #Get a response from the site.
        $HTTP_Response = $HTTP_Request.GetResponse()

        # Get the HTTP code as an integer.
        $HTTP_Status = [int]$HTTP_Response.StatusCode

        If ($HTTP_Status -eq 200) 
        { 
            Write-Verbose "Site is up and running"
            return $true
        }
        Else 
        {
            Write-Verbose "Site might be down."
            return $false
        }
    }
    catch
    {
        Write-Verbose "Error: $_"
        return $false
    }
}