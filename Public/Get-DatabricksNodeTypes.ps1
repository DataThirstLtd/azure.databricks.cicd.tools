<#
.SYNOPSIS
Get a list of Node types available for use.

.DESCRIPTION
Get a list of Node types available for use.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.EXAMPLE
PS C:\> Get-DatabricksNodeTypes -BearerToken $BearerToken -Region $Region

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Get-DatabricksNodeTypes
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    
    Try {
        $Nodes = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/clusters/list-node-types" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return $Nodes.node_types
}
    