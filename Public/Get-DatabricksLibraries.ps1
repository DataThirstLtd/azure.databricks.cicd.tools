<#
.SYNOPSIS
Get a list of Libraries and their statuses for a Databricks cluster

.DESCRIPTION
Get a list of Libraries and their statuses for a Databricks cluster

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ClusterId
ClusterId for existing Databricks cluster. Does not need to be running. See Get-DatabricksClusters.

.PARAMETER returnCluster
Switch that returns the entire object.

.EXAMPLE
PS C:\> Get-DatabricksLibraries -BearerToken $BearerToken -Region $Region -ClusterId 'Bob-1234'

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Get-DatabricksLibraries { 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$ClusterId,
        [parameter(Mandatory = $false)][switch]$returnCluster
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    
    $Uri = "$global:DatabricksURI/api/2.0/libraries/cluster-status?cluster_id=$ClusterId"

    Try {
        $Libraries = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }
    if ($PSBoundParameters.ContainsKey('returnCluster') -eq $false) {

        Return $Libraries.library_statuses
    }
    else {
        $Libraries
    }
}
    