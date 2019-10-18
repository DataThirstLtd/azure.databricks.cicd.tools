<#
.SYNOPSIS
Gets a list of Service principals that have been provisioned in the workspace

.DESCRIPTION
Gets a list of Service principals that have been provisioned in the workspace

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER DatabricksId
Optional. Returns just a single service principal using the internal Databricks Id.

.PARAMETER ServicePrincipalId
Optional. Returns just a single service principal using the ServicePrincipalId/ApplicationId/ClientId.

.EXAMPLE
PS C:\> Get-DatabricksServicePrincipals -BearerToken $BearerToken -Region $Region

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksServicePrincipals
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName='Bearer')]
        [parameter(Mandatory = $false, ParameterSetName='AAD')]
        [string]$Region,
        
        [parameter(Mandatory = $false)]
        [string]$DatabricksId,
        [parameter(Mandatory = $false)]
        [string]$ServicePrincipalId
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters
    $URIExtras = ""

    if ($PSBoundParameters.ContainsKey('DatabricksId')){
        $URIExtras = "/$DatabricksId"
    }
    if ($PSBoundParameters.ContainsKey('ServicePrincipalId')){
        $URIExtras = "?filter=applicationId+eq+$ServicePrincipalId"
    }

    $URI = "$global:DatabricksURI/api/2.0/preview/scim/v2/ServicePrincipals$URIExtras"
    Write-Verbose $URI
    $Response = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers


    if ([bool]($Response.PSobject.Properties.name -match "Resources")){
        return $Response.Resources
    }
    else{
        return $Response
    }
}
    