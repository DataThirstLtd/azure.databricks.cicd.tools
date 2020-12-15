<#
.SYNOPSIS
Called in Connect-Databricks when switch TestConnectDatabricks is included

.DESCRIPTION
Called in Connect-Databricks when switch TestConnectDatabricks is included

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.EXAMPLE
PS C:\> Test-ConnectDatabricks -BearerToken $BearerToken -Region $Region

.NOTES
Author: Richie Lee 

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
    