<#

.SYNOPSIS
    Pin or unpin a DB cluster

.DESCRIPTION
    Pin or unpin a DB cluster

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER $enablePin
    $true to pin, $false to unpin

.PARAMETER $clusterId
    Id of the cluster to be processed



#>

Function Set-DatabricksClusterPinStatus {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][boolean]$enablePin,
        [parameter(Mandatory = $true)][string]$clusterId
    )

    $Headers = GetHeaders $PSBoundParameters

    $body = '{ "cluster_id": "' + $clusterId + '"}'

    if ($enablePin) {
        Invoke-RestMethod -Method Post -Body $body -Uri "$global:DatabricksURI/api/2.0/clusters/pin" -Headers $Headers
    }
    else {
        Invoke-RestMethod -Method Post -Body $body -Uri "$global:DatabricksURI/api/2.0/clusters/unpin" -Headers $Headers
    }
}


