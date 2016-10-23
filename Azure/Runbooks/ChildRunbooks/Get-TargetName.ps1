<#
.SYNOPSIS
    Appends or removes a suffix from a given file name.

.DESCRIPTION
    This runbook appends or removes a suffix from a given file name based on input parameters. 
    
.PARAMETER sourceName
     String name of the source file. 

.PARAMETER suffix
     String suffix that needs to be appended or removed to get the target file name. 

.PARAMETER ToAppendOrToRemove
     String "Append" if the suffix is needed to be appended to the file name.
            "Remove" if the suffix is needed to be removed from the file name.
        
.NOTES
    Author: Microsoft GD Team
    Version 1.1   
#>
Workflow Get-TargetName
{
    param
    (
        [string] $sourceName,
        [string] $suffix,
        [string] $ToAppendOrToRemove
    )
    Write-Log -Level 15 -Message "`r`n*****************Begin workflow: Get-TargetName***************** `r`nInput Params: `r`nsourceName = $sourceName, `r`nsuffix = $suffix, `r`nToAppendOrToRemove = $ToAppendOrToRemove`r`n" -RunbookName Get-TargetName       

    $destName = ""
    if($suffix -eq $null)
    {
        $destName = $sourceName
    }
    elseif ($ToAppendOrToRemove -ieq "Append")
    {
        $file = Split-Path -Path $sourceName -leaf
        $arr = $file.Split('.')
        $fileExtn = $arr[$arr.Length - 1]

        $index = $sourceName.LastIndexOf(".$fileExtn")
        $fileWithoutExtn = $sourceName.Remove($index, $fileExtn.Length + 1)
        $destName = "$fileWithoutExtn" + "-$suffix" + ".$fileExtn"
    }
    elseif ($ToAppendOrToRemove -ieq "Remove")
    {
        
        $index = $sourceName.LastIndexOf("-$suffix")
        $destName = $sourceName.Remove($index, $suffix.Length + 1)
    }
    Write-Log -Level 15 -Message "The output for source name '$sourceName' is: '$destName'" -RunbookName Get-TargetName       
    Write-Log -Level 15 -Message "`r`n*****************End workflow: Get-TargetName*****************`r`nToAppendOrToRemove = $ToAppendOrToRemove`r`n" -RunbookName Get-TargetName       

    return $destName
}