<#
.SYNOPSIS
Get a list of Spark versions available for use.

.DESCRIPTION
Get a list of Spark versions available for use.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.EXAMPLE
PS C:\> Get-DatabricksSparkVersions -BearerToken $BearerToken -Region $Region

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#> 

Function Get-DatabricksSparkVersions
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    Try {
        $Versions = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/clusters/spark-versions" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return $Versions.versions
}
    