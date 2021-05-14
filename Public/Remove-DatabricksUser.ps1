<#
.SYNOPSIS
Delete a user from Databricks with given user name

.DESCRIPTION
Delete a group from Databricks with given user name

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER UserName
   Name for the user that will be deleted.
#>
Function Remove-DatabricksUser {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AAD')]
        [string]$Region,

        [parameter(Mandatory = $true)][string]$UserId
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
 
    $uri = "$global:DatabricksURI" + (Get-SCIMURL "Users") + "/$UserId"
    $schemaR = Add-SCIMSchema "urn:ietf:params:scim:schemas:core:2.0:User"
    $Request = Invoke-RestMethod -Method Delete -Uri $uri -Headers $Headers -ContentType "application/scim+json"
}