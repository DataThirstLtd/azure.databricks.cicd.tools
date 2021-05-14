<#

.SYNOPSIS
    Get all cluster policies

.DESCRIPTION
    Get all cluster policies

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.EXAMPLE 
Get-DatabricksPolicies -BearerToken $BearerToken -Region $Region 

This example get all a cluster policies

#>
Function Get-DatabricksPolicies {
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

    Write-host "Found cluster policies"

    return $policies[0].policies
}