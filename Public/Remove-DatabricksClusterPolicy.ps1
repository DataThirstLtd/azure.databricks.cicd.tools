<#

.SYNOPSIS
    Remove a cluster policy

.DESCRIPTION
    Get all cluster policies

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Id
    Id of a policy to be removed

.EXAMPLE 
Remove-DatabricksPolicies -BearerToken $BearerToken -Region $Region -Id 1234

#>
Function Remove-DatabricksClusterPolicy {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AAD')]
        [string]$Region,

        [parameter(Mandatory = $false)][string]$Id
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    $Body = @{
        policy_id = $id
    }
    $BodyText = $Body | ConvertTo-Json

    Invoke-RestMethod -Method POST -Uri "$global:DatabricksURI/api/2.0/policies/clusters/delete" -Headers $Headers -Body $BodyText
}