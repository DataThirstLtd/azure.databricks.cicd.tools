<#

.SYNOPSIS
    Gets a list of permission levels available for an object

.DESCRIPTION
    Gets a list of permission levels available for an object

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER DatabricksObjectType
    Job, Cluster or Instance-pool

.PARAMETER DatabricksObjectId
    JobUd, ClusterId or Instance-poolId

.EXAMPLE 
    C:\PS> Get-DatabricksPermissionLevels -BearerToken $BearerToken -Region $Region -DatabricksObjectType "job" -DatabricksObjectId 121

    This example creates a scope called Test1 if it does not exist and a secret called MySecretName with a value of P@ssword.

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksPermissionLevels
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$false)][string]$BearerToken,
        [parameter(Mandatory=$false)][string]$Region,
        [Parameter(Mandatory=$true)][ValidateSet('job','cluster','instance-pool')][string]$DatabricksObjectType,
        [Parameter(Mandatory=$true)][string]$DatabricksObjectId
    )

    $Headers = GetHeaders $PSBoundParameters
    $BasePath = "$global:DatabricksURI/api/2.0/preview"
    $URI =  "$BasePath/permissions/$DatabricksObjectType" + "s/$DatabricksObjectId/permissionLevels"
  
    $Response = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers
    
    return $Response
}


