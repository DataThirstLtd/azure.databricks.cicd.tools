<#
.SYNOPSIS
Pulls the contents of a Databricks folder (and subfolders) locally so that they can be committed to a repo

.DESCRIPTION
Pulls the contents of a Databricks folder (and subfolders) locally so that they can be committed to a repo

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ClusterId
Optional. Returns just a single cluster.

.EXAMPLE
PS C:\> Get-DatabricksClusters -BearerToken $BearerToken -Region $Region

Returns all clusters

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksClusters 
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $false)][string]$ClusterId
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders
    Write-Host "Hi"
    Try {
        $Clusters = Invoke-RestMethod -Method Get -Uri "$script:DatabricksURI/api/2.0/clusters/list" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    if ($PSBoundParameters.ContainsKey('ClusterId')){
        $Result = $Clusters.clusters | Where-Object {$_.cluster_id -eq $ClusterId}
        Return $Result
    }
    else {
        Return $Clusters.clusters
    }

}
    