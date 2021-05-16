<#
.SYNOPSIS
Delete a user from Databricks with given user name

.DESCRIPTION
Delete a group from Databricks with given user name

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Id
Id of a user in a scenario of search by Id
#> 

Function Get-DatabricksUsers { 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AAD')]
        [string]$Region,

        [parameter(Mandatory = $false)][string]$id = $null
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 

    if ($id) {
        $uri = "$global:DatabricksURI" + (Get-SCIMURL "Users") + "/$id" 
    }
    else {
        $uri = "$global:DatabricksURI" + (Get-SCIMURL "Users")
    }

    $users = Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers -ContentType "application/scim+json"

    return $users
}