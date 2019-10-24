<#
.SYNOPSIS
Get a list of Datbricks Clusters

.DESCRIPTION
Get a list of Datbricks Clusters

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
        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName='Bearer')]
        [parameter(Mandatory = $false, ParameterSetName='AAD')]
        [string]$Region,
        
        [parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$ClusterId
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    Try {
        $Clusters = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/clusters/list" -Headers $Headers
    }
    Catch {
        Write-Error "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Error "StatusDescription:" $_.Exception.Response.StatusDescription
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
    