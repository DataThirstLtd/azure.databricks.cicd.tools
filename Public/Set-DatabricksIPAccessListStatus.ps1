<#

.SYNOPSIS
    Enable/disable IP access list feature for the workspace

.DESCRIPTION
The IP Access List API enables Azure Databricks admins to configure IP allow lists and block lists for a workspace.
If the feature is disabled for a workspace, all access is allowed.
There is support for allow lists (inclusion) and block lists (exclusion).

Be sure to check the doc before using this feature:
https://docs.microsoft.com/en-us/azure/databricks/security/network/ip-access-list

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER enabled
    $true enables IP access list feature for the workspace.
    $false disables it.

#>

Function Set-DatabricksIPAccessListStatus {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AAD')]
        [string]$Region,

        [parameter(Mandatory=$true)][boolean]$enabled
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    $Body = '{"enableIpAccessLists": "' + $enabled.ToString().ToLower() + '"}'

    Invoke-RestMethod -Method Patch `
        -Body $Body `
        -Uri "$global:DatabricksURI/api/2.0/workspace-conf" `
        -Headers $Headers `
        -ContentType "application/json"
}