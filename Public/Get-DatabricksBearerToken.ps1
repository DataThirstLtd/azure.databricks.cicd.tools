<#
.SYNOPSIS
Returns a list of existing bearer token (note the actual token cannot be returned - use New-DatabricksBearerToken)

.DESCRIPTION
Returns a list of existing bearer token (note the actual token cannot be returned - use New-DatabricksBearerToken)

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.EXAMPLE
PS C:\> Get-DatabricksRun -BearerToken $BearerToken -Region $Region -RunId 10


.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksBearerToken
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    Return Invoke-DatabricksAPI  -Method GET -API "api/2.0/token/list" 
    
}
    