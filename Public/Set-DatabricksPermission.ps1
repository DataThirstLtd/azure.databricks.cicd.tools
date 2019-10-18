<#

.SYNOPSIS
    Add permissions to objects

.DESCRIPTION
    Add permissions to objects

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Principal
    "user_name"​​ || ​"group_name"​ ​|| "service_principal_name"

.PARAMETER PermissionLevel
    See Get-DatabricksPermissionLevels

.PARAMETER DatabricksObjectType
    Job, Cluster or Instance-pool

.PARAMETER DatabricksObjectId
    JobUd, ClusterId or Instance-poolId

.EXAMPLE 
    C:\PS> Set-DatabricksPermission -BearerToken $BearerToken -Region $Region -Principal "MyTestGroup" -PermissionLevel 'CAN_MANAGE' -DatabricksObjectType 'Cluster' -DatabricksObjectId "tubby-1234"

    This adds the permission CAN_MANAGE to a cluster for all users in the MyTestGroup

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

Function Set-DatabricksPermission
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$false)][string]$BearerToken,
        [parameter(Mandatory=$false)][string]$Region,
        [parameter(Mandatory=$true)][string]$Principal,
        [Parameter(Mandatory=$true)][string]$PermissionLevel,
        [Parameter(Mandatory=$true)][ValidateSet('job','cluster','instance-pool')][string]$DatabricksObjectType,
        [Parameter(Mandatory=$true)][string]$DatabricksObjectId
    )

    $Headers = GetHeaders $PSBoundParameters
    $BasePath = "$global:DatabricksURI/api/2.0/preview"
    $URI =  "$BasePath/permissions/$DatabricksObjectType" + "s/$DatabricksObjectId"
  
    $acl = @(@{"user_name"= $Principal; "permission_level"=$PermissionLevel})
    $Body = @{"access_control_list"= $acl} | ConvertTo-Json -Depth 10

    Write-Verbose $Body
    $Response = Invoke-RestMethod -Method PATCH -Body $Body -Uri $URI -Headers $Headers
    
    return $Response
}


