<#
.SYNOPSIS
    Writes verbose and error messages.

.DESCRIPTION
    This runbook writes verbose and error messages. Each message has a log level associated with it. 
    Only those messages would be logged, that have log level higher than the configurable azure asset value. 
    
.PARAMETER Level
     Log level of the message.  

.PARAMETER Message
     Message to be logged. 

.PARAMETER RunbookName
     Runbook from which log request in invoked.
        
.PARAMETER IsError
     $true if the message is to be logged as an error.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
workflow Write-Log
{
    param (
       [Parameter(Mandatory=$False)]
       [int] $Level = 3,
       [Parameter(Mandatory=$False)]
       [string] $Message = "No message is passed to logging function!",
       [Parameter(Mandatory=$False)]
       [string] $RunbookName = "No runbook name given",
       [Parameter(Mandatory=$False)]
       [bool] $IsError = $False,
       [Parameter(Mandatory=$False)]
       [string] $OperationID
    )
    
    $VerbosePreference = "Continue"
    
    # Retrieve our global Azure error logging level
    $globalLogLevel = 20
    
    # Log an error if error level is less than global level
    if ($level -le $globalLogLevel)
    {
        #Not logging time and operation ID currently
        #$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss.000"
        #if(!$OperationID)
        #{
        #    $OperationID = [GUID]::NewGuid()
        #}
        
        if($IsError) 
        {
            Write-Error "`r`nRunbookName:$RunbookName,`tMessage:$Message"
        }
        else
        {
            Write-Verbose "`r`nRunbookName:$RunbookName,`tMessage:$Message"  
        }
    }
}