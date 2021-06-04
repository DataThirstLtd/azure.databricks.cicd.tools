<#

.SYNOPSIS
Return information about all pinned clusters, active clusters, up to 100 of the most recently terminated all-purpose clusters in the past 30 days, and up to 30 of the most recently terminated job clusters in the past 30 days.

.DESCRIPTION
Return information about all pinned clusters, active clusters, up to 100 of the most recently terminated all-purpose clusters in the past 30 days, and up to 30 of the most recently terminated job clusters in the past 30 days.

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope


#>

Function Get-DatabricksClusterPinStatus {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,
        [parameter(Mandatory = $false)][string]$Region
    )

    $Headers = GetHeaders $PSBoundParameters
    $response = Invoke-RestMethod -Method Get -Body $body -Uri "$global:DatabricksURI/api/2.0/clusters/list" -Headers $Headers

    return $response.clusters
}


