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

Function Test-ConnectDatabricks { 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    try {
        Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/clusters/spark-versions" -Headers $Headers | Out-Null
    }
    catch {
        Write-Error $_.Exception.Response
        Throw
    }
}
    