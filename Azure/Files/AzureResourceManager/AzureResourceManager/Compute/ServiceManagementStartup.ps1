﻿# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

$aliases = @{
    # Profile aliases
    "Get-WAPackPublishSettingsFile" = "Get-AzurePublishSettingsFile";
    "Get-WAPackSubscription" = "Get-AzureSubscription";
    "Import-WAPackPublishSettingsFile" = "Import-AzurePublishSettingsFile";
    "Remove-WAPackSubscription" = "Remove-AzureSubscription";
    "Select-WAPackSubscription" = "Select-AzureSubscription";
    "Set-WAPackSubscription" = "Set-AzureSubscription";
    "Show-WAPackPortal" = "Show-AzurePortal";
    "Test-WAPackName" = "Test-AzureName";
    "Get-WAPackEnvironment" = "Get-AzureEnvironment";
    "Add-WAPackEnvironment" = "Add-AzureEnvironment";
    "Set-WAPackEnvironment" = "Set-AzureEnvironment";
    "Remove-WAPackEnvironment" = "Remove-AzureEnvironment";

    # Websites aliases
    "New-WAPackWebsite" = "New-AzureWebsite";
    "Get-WAPackWebsite" = "Get-AzureWebsite";
    "Set-WAPackWebsite" = "Set-AzureWebsite";
    "Remove-WAPackWebsite" = "Remove-AzureWebsite";
    "Start-WAPackWebsite" = "Start-AzureWebsite";
    "Stop-WAPackWebsite" = "Stop-AzureWebsite";
    "Restart-WAPackWebsite" = "Restart-AzureWebsite";
    "Show-WAPackWebsite" = "Show-AzureWebsite";
    "Get-WAPackWebsiteLog" = "Get-AzureWebsiteLog";
    "Save-WAPackWebsiteLog" = "Save-AzureWebsiteLog";
    "Get-WAPackWebsiteLocation" = "Get-AzureWebsiteLocation";
    "Get-WAPackWebsiteDeployment" = "Get-AzureWebsiteDeployment";
    "Restore-WAPackWebsiteDeployment" = "Restore-AzureWebsiteDeployment";
    "Enable-WAPackWebsiteApplicationDiagnositc" = "Enable-AzureWebsiteApplicationDiagnostic";
    "Disable-WAPackWebsiteApplicationDiagnostic" = "Disable-AzureWebsiteApplicationDiagnostic";

    # Service Bus aliases
    "Get-WAPackSBLocation" = "Get-AzureSBLocation";
    "Get-WAPackSBNamespace" = "Get-AzureSBNamespace";
    "New-WAPackSBNamespace" = "New-AzureSBNamespace";
    "Remove-WAPackSBNamespace" = "Remove-AzureSBNamespace";

    # Storage aliases
    "Get-AzureStorageContainerAcl" = "Get-AzureStorageContainer";
    "Start-CopyAzureStorageBlob" = "Start-AzureStorageBlobCopy";
    "Stop-CopyAzureStorageBlob" = "Stop-AzureStorageBlobCopy";

    # Compute aliases
    "New-AzureDns" = "New-AzureDnsConfig";
    
    # HDInsight aliases
    "Invoke-Hive" = "Invoke-AzureHDInsightHiveJob";
    "hive" = "Invoke-AzureHDInsightHiveJob";

    #StorSimple aliases
    "Get-SSAccessControlRecord" = "Get-AzureStorSimpleAccessControlRecord" ;
    "Get-SSDevice"= "Get-AzureStorSimpleDevice" ;
    "Get-SSDeviceBackup" = "Get-AzureStorSimpleDeviceBackup" ;
    "Get-SSDeviceBackupPolicy" = "Get-AzureStorSimpleDeviceBackupPolicy" ;
    "Get-SSDeviceConnectedInitiator" = "Get-AzureStorSimpleDeviceConnectedInitiator" ;
    "Get-SSDeviceVolume" = "Get-AzureStorSimpleDeviceVolume" ;
    "Get-SSDeviceVolumeContainer" = "Get-AzureStorSimpleDeviceVolumeContainer" ;
    "Get-SSFailoverVolumeContainers" = "Get-AzureStorSimpleFailoverVolumeContainers" ;
    "Get-SSJob" = "Get-AzureStorSimpleJob" ;
    "Get-SSResource" = "Get-AzureStorSimpleResource" ;
    "Get-SSResourceContext" = "Get-AzureStorSimpleResourceContext" ;
    "Get-SSStorageAccountCredential" = "Get-AzureStorSimpleStorageAccountCredential" ;
    "Get-SSTask" = "Get-AzureStorSimpleTask" ;
    "New-SSAccessControlRecord" = "New-AzureStorSimpleAccessControlRecord" ;
    "New-SSDeviceBackupPolicy" = "New-AzureStorSimpleDeviceBackupPolicy" ;
    "New-SSDeviceBackupScheduleAddConfig" = "New-AzureStorSimpleDeviceBackupScheduleAddConfig" ;
    "New-SSDeviceBackupScheduleUpdateConfig" = "New-AzureStorSimpleDeviceBackupScheduleUpdateConfig" ;
    "New-SSDeviceVolume" = "New-AzureStorSimpleDeviceVolume";
    "New-SSDeviceVolumeContainer" = "New-AzureStorSimpleDeviceVolumeContainer" ;
    "New-SSInlineStorageAccountCredential" = "New-AzureStorSimpleInlineStorageAccountCredential" ;
    "New-SSNetworkConfig" = "New-AzureStorSimpleNetworkConfig";
    "New-SSStorageAccountCredential" = "New-AzureStorSimpleStorageAccountCredential";
    "New-SSVirtualDevice" = "New-AzureStorSimpleVirtualDevice";
    "Remove-SSAccessControlRecord" = "Remove-AzureStorSimpleAccessControlRecord";
    "Remove-SSDeviceBackup" = "Remove-AzureStorSimpleDeviceBackup";
    "Remove-SSDeviceBackupPolicy" = "Remove-AzureStorSimpleDeviceBackupPolicy";
    "Remove-SSDeviceVolume" = "Remove-AzureStorSimpleDeviceVolume";
    "Remove-SSDeviceVolumeContainer" = "Remove-AzureStorSimpleDeviceVolumeContainer";
    "Remove-SSStorageAccountCredential" = "Remove-AzureStorSimpleStorageAccountCredential";
    "Select-SSResource" = "Select-AzureStorSimpleResource";
    "Set-SSAccessControlRecord" = "Set-AzureStorSimpleAccessControlRecord";
    "Set-SSDevice" = "Set-AzureStorSimpleDevice";
    "Set-SSDeviceBackupPolicy" = "Set-AzureStorSimpleDeviceBackupPolicy";
    "Set-SSDeviceVolume" = "Set-AzureStorSimpleDeviceVolume";
    "Set-SSStorageAccountCredential" = "Set-AzureStorSimpleStorageAccountCredential";
    "Set-SSVirtualDevice" = "Set-AzureStorSimpleVirtualDevice";
    "Start-SSBackupCloneJob" = "Start-AzureStorSimpleBackupCloneJob";
    "Start-SSDeviceBackupJob" = "Start-AzureStorSimpleDeviceBackupJob";
    "Start-SSDeviceBackupRestoreJob" = "Start-AzureStorSimpleDeviceBackupRestoreJob";
    "Start-SSDeviceFailoverJob" = "Start-AzureStorSimpleDeviceFailoverJob";
    "Stop-SSJob" = "Stop-AzureStorSimpleJob";	
    "Confirm-SSLegacyVolumeContainerStatus" = "Confirm-AzureStorSimpleLegacyVolumeContainerStatus";
    "Get-SSLegacyVolumeContainerConfirmStatus" = "Get-AzureStorSimpleLegacyVolumeContainerConfirmStatus";
    "Get-SSLegacyVolumeContainerMigrationPlan" = "Get-AzureStorSimpleLegacyVolumeContainerMigrationPlan";
    "Get-SSLegacyVolumeContainerStatus" = "Get-AzureStorSimpleLegacyVolumeContainerStatus";
    "Import-SSLegacyApplianceConfig" = "Import-AzureStorSimpleLegacyApplianceConfig";
    "Import-SSLegacyVolumeContainer" = "Import-AzureStorSimpleLegacyVolumeContainer";
    "Start-SSLegacyVolumeContainerMigrationPlan" = "Start-AzureStorSimpleLegacyVolumeContainerMigrationPlan";
}

$aliases.GetEnumerator() | Select @{Name='Name'; Expression={$_.Key}}, @{Name='Value'; Expression={$_.Value}} | New-Alias -Description "AzureAlias"
# SIG # Begin signature block
# MIIaqwYJKoZIhvcNAQcCoIIanDCCGpgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSb1KrMU4fOG98TXTnWEl8Y4o
# hfSgghWCMIIEwzCCA6ugAwIBAgITMwAAAHGzLoprgqofTgAAAAAAcTANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTUwMzIwMTczMjAz
# WhcNMTYwNjIwMTczMjAzWjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OkI4RUMtMzBBNC03MTQ0MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6pG9soj9FG8h
# NigDZjM6Zgj7W0ukq6AoNEpDMgjAhuXJPdUlvHs+YofWfe8PdFOj8ZFjiHR/6CTN
# A1DF8coAFnulObAGHDxEfvnrxLKBvBcjuv1lOBmFf8qgKf32OsALL2j04DROfW8X
# wG6Zqvp/YSXRJnDSdH3fYXNczlQqOVEDMwn4UK14x4kIttSFKj/X2B9R6u/8aF61
# wecHaDKNL3JR/gMxR1HF0utyB68glfjaavh3Z+RgmnBMq0XLfgiv5YHUV886zBN1
# nSbNoKJpULw6iJTfsFQ43ok5zYYypZAPfr/tzJQlpkGGYSbH3Td+XA3oF8o3f+gk
# tk60+Bsj6wIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFPj9I4cFlIBWzTOlQcJszAg2
# yLKiMB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAC0EtMopC1n8Luqgr0xOaAT4ku0pwmbMa3DJh+i+h/xd9N1P
# pRpveJetawU4UUFynTnkGhvDbXH8cLbTzLaQWAQoP9Ye74OzFBgMlQv3pRETmMaF
# Vl7uM7QMN7WA6vUSaNkue4YIcjsUe9TZ0BZPwC8LHy3K5RvQrumEsI8LXXO4FoFA
# I1gs6mGq/r1/041acPx5zWaWZWO1BRJ24io7K+2CrJrsJ0Gnlw4jFp9ByE5tUxFA
# BMxgmdqY7Cuul/vgffW6iwD0JRd/Ynq7UVfB8PDNnBthc62VjCt2IqircDi0ASh9
# ZkJT3p/0B3xaMA6CA1n2hIa5FSVisAvSz/HblkUwggTsMIID1KADAgECAhMzAAAA
# ymzVMhI1xOFVAAEAAADKMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBMB4XDTE0MDQyMjE3MzkwMFoXDTE1MDcyMjE3MzkwMFowgYMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJZxXe0GRvqEy51bt0bHsOG0ETkDrbEVc2Cc66e2bho8
# P/9l4zTxpqUhXlaZbFjkkqEKXMLT3FIvDGWaIGFAUzGcbI8hfbr5/hNQUmCVOlu5
# WKV0YUGplOCtJk5MoZdwSSdefGfKTx5xhEa8HUu24g/FxifJB+Z6CqUXABlMcEU4
# LYG0UKrFZ9H6ebzFzKFym/QlNJj4VN8SOTgSL6RrpZp+x2LR3M/tPTT4ud81MLrs
# eTKp4amsVU1Mf0xWwxMLdvEH+cxHrPuI1VKlHij6PS3Pz4SYhnFlEc+FyQlEhuFv
# 57H8rEBEpamLIz+CSZ3VlllQE1kYc/9DDK0r1H8wQGcCAwEAAaOCAWAwggFcMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQfXuJdUI1Whr5KPM8E6KeHtcu/
# gzBRBgNVHREESjBIpEYwRDENMAsGA1UECxMETU9QUjEzMDEGA1UEBRMqMzE1OTUr
# YjQyMThmMTMtNmZjYS00OTBmLTljNDctM2ZjNTU3ZGZjNDQwMB8GA1UdIwQYMBaA
# FMsR6MrStBZYAck3LjMWFrlMmgofMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8w
# OC0zMS0yMDEwLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzA4LTMx
# LTIwMTAuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQB3XOvXkT3NvXuD2YWpsEOdc3wX
# yQ/tNtvHtSwbXvtUBTqDcUCBCaK3cSZe1n22bDvJql9dAxgqHSd+B+nFZR+1zw23
# VMcoOFqI53vBGbZWMrrizMuT269uD11E9dSw7xvVTsGvDu8gm/Lh/idd6MX/YfYZ
# 0igKIp3fzXCCnhhy2CPMeixD7v/qwODmHaqelzMAUm8HuNOIbN6kBjWnwlOGZRF3
# CY81WbnYhqgA/vgxfSz0jAWdwMHVd3Js6U1ZJoPxwrKIV5M1AHxQK7xZ/P4cKTiC
# 095Sl0UpGE6WW526Xxuj8SdQ6geV6G00DThX3DcoNZU6OJzU7WqFXQ4iEV57MIIF
# vDCCA6SgAwIBAgIKYTMmGgAAAAAAMTANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZIm
# iZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQD
# EyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMTAwODMx
# MjIxOTMyWhcNMjAwODMxMjIyOTMyWjB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJyWVwZMGS/HZpgICBC
# mXZTbD4b1m/My/Hqa/6XFhDg3zp0gxq3L6Ay7P/ewkJOI9VyANs1VwqJyq4gSfTw
# aKxNS42lvXlLcZtHB9r9Jd+ddYjPqnNEf9eB2/O98jakyVxF3K+tPeAoaJcap6Vy
# c1bxF5Tk/TWUcqDWdl8ed0WDhTgW0HNbBbpnUo2lsmkv2hkL/pJ0KeJ2L1TdFDBZ
# +NKNYv3LyV9GMVC5JxPkQDDPcikQKCLHN049oDI9kM2hOAaFXE5WgigqBTK3S9dP
# Y+fSLWLxRT3nrAgA9kahntFbjCZT6HqqSvJGzzc8OJ60d1ylF56NyxGPVjzBrAlf
# A9MCAwEAAaOCAV4wggFaMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMsR6MrS
# tBZYAck3LjMWFrlMmgofMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBT90TFO0yaKleGYYDuoMW+mPLzYLTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQOrIJgQFYnl+UlE/wq4QpTlVnk
# pDBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEE
# SDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDANBgkqhkiG9w0BAQUFAAOCAgEAWTk+
# fyZGr+tvQLEytWrrDi9uqEn361917Uw7LddDrQv+y+ktMaMjzHxQmIAhXaw9L0y6
# oqhWnONwu7i0+Hm1SXL3PupBf8rhDBdpy6WcIC36C1DEVs0t40rSvHDnqA2iA6VW
# 4LiKS1fylUKc8fPv7uOGHzQ8uFaa8FMjhSqkghyT4pQHHfLiTviMocroE6WRTsgb
# 0o9ylSpxbZsa+BzwU9ZnzCL/XB3Nooy9J7J5Y1ZEolHN+emjWFbdmwJFRC9f9Nqu
# 1IIybvyklRPk62nnqaIsvsgrEA5ljpnb9aL6EiYJZTiU8XofSrvR4Vbo0HiWGFzJ
# NRZf3ZMdSY4tvq00RBzuEBUaAF3dNVshzpjHCe6FDoxPbQ4TTj18KUicctHzbMrB
# 7HCjV5JXfZSNoBtIA1r3z6NnCnSlNu0tLxfI5nI3EvRvsTxngvlSso0zFmUeDord
# EN5k9G/ORtTTF+l5xAS00/ss3x+KnqwK+xMnQK3k+eGpf0a7B2BHZWBATrBC7E7t
# s3Z52Ao0CW0cgDEf4g5U3eWh++VHEK1kmP9QFi58vwUheuKVQSdpw5OPlcmN2Jsh
# rg1cnPCiroZogwxqLbt2awAdlq3yFnv2FoMkuYjPaqhHMS+a3ONxPdcAfmJH0c6I
# ybgY+g5yjcGjPa8CQGr/aZuW4hCoELQ3UAjWwz0wggYHMIID76ADAgECAgphFmg0
# AAAAAAAcMA0GCSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAX
# BgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMx
# MzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
# BgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJ+hbLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn
# 0UytdDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0
# Zxws/HvniB3q506jocEjU8qN+kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4n
# rIZPVVIM5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YR
# JylmqJfk0waBSqL5hKcRRxQJgp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54
# QTF3zJvfO4OToWECtR0Nsfz3m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8G
# A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsG
# A1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJg
# QFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcG
# CgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3Qg
# Q2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJ
# MEcwRaBDoEGGP2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYB
# BQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9z
# b2Z0Um9vdENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
# BQUAA4ICAQAQl4rDXANENt3ptK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1i
# uFcCy04gE1CZ3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+r
# kuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGct
# xVEO6mJcPxaYiyA/4gcaMvnMMUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/F
# NSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbo
# nXCUbKw5TNT2eb+qGHpiKe+imyk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0
# NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPp
# K+m79EjMLNTYMoBMJipIJF9a6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2J
# oXZhtG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0
# eFQF1EEuUKyUsKV4q7OglnUa2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng
# 9wFlb4kLfchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8uVRZryROj/TGCBJMwggSP
# AgEBMIGQMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBAhMzAAAAymzVMhI1xOFV
# AAEAAADKMAkGBSsOAwIaBQCggawwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFN1G
# pPQELVEsp4ut3h+i+AuxS5a6MEwGCisGAQQBgjcCAQwxPjA8oCKAIABBAHoAdQBy
# AGUAIABQAG8AdwBlAHIAUwBoAGUAbABsoRaAFGh0dHA6Ly9Db2RlU2lnbkluZm8g
# MA0GCSqGSIb3DQEBAQUABIIBADVFH2ZHtjPz51o4WNvpvhYztxiK38z8ZK/wtTTy
# FuMSk1rFxjq4hDmAazM6vhDbYklO6gKQ4+DiS1bXL7yplh4EeuOhv1NNsxmU+9SS
# KLqNB5/E9+ULYPyTjTdAd63KrS3farBMmWR0HLKG681ToF8T1HptfGrZ2/elK+XK
# J/0rDd8J3urhSDRUPobMzRQ+HVB7tPCkRmWV033ttmP3/CfNmdm3KjRM2b81TQZL
# i4GJCbH0ACQuSlhIRqOJTcvDV6ZcCTBVebET/1rbYYDleHBnAxatKoDVJWHUd3n4
# gvnQWRmBnKfIc60GSPX4sXrqeryX7BSP4J5OV4YP+CaliY6hggIoMIICJAYJKoZI
# hvcNAQkGMYICFTCCAhECAQEwgY4wdzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBAhMz
# AAAAcbMuimuCqh9OAAAAAABxMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJ
# KoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNTA2MDMwMDIyMzdaMCMGCSqGSIb3
# DQEJBDEWBBQI36v6Pr1CGATxNRxZehfNvitChTANBgkqhkiG9w0BAQUFAASCAQDP
# 9zYhMD6UzOIN3XCPQE57UKeFZgvpYytert5LEJTTywz3I84VyFsTtG71AuJDnTH3
# 2cCCYwr+yfAHDVCO7+XPgT4Tygr8LWuHB3LRoCQap/fOrBoC6sLTiBpi7XgYo9S4
# 4pl1mq5MTUAc0rIYyTEM9xjm7kybCo0LSd5R40SYhH0sC6YnnNpTPNb8YVstK1qK
# wbGF00pvDPVCS19qGDbuwEvc6o+APhbNCxf7FOLYmECjmNNQj2RfsgaY9t0fA+BH
# DDrkZVh2kphTTLCLYdGdfu/dPE9Wbmn3gFxAtpaTKgIFoGiYNDRA+Ysr0FRTyAVE
# BoNZ85iv1pIhysGNcNdL
# SIG # End signature block
