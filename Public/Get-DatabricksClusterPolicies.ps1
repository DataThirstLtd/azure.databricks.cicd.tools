<#

.SYNOPSIS
    Get all cluster policies

.DESCRIPTION
    Get all cluster policies

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Id
    Id of a policy in the context of a search by Id

.EXAMPLE 
Get-DatabricksPolicies -BearerToken $BearerToken -Region $Region 
Get-DatabricksPolicies -BearerToken $BearerToken -Region $Region -Id 1234


#>
Function Get-DatabricksClusterPolicies {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AAD')]
        [string]$Region
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    [Array]$policies = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/policies/clusters/list" -Headers $Headers
    return $policies[0].policies

}