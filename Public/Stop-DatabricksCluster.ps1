<#
.SYNOPSIS
Stops a Databricks cluster or set of clusters with the same name.

.DESCRIPTION
Stops a Databricks cluster or set of clusters with the same name.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ClusterName
Optional. Will stop all clusters with this name.

.PARAMETER ClusterId
Optional. See Get-DatabricksClusters. Will stop this cluster only if provided.

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Stop-DatabricksCluster {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,    
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $false)][string]$ClusterName,
        [parameter(Mandatory = $false)][string]$ClusterId
        )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters
    
    
    $body = @{}
    $ClusterIds = @()

    If ($PSBoundParameters.ContainsKey('ClusterId')) {
        $ClusterIds += $ClusterId
    }
    elseif ($PSBoundParameters.ContainsKey('ClusterName')) {
        $Clusters = (Get-DatabricksClusters | Where-Object {$_.cluster_name -eq $ClusterName})
        foreach ($c in $Clusters)
        {
            $ClusterIds += $c.cluster_id
        }
    }
    else{
        Write-Error "You must specify ClusterId or ClusterName"
        return
    }
    

    foreach ($ClusterId in $ClusterIds)
    {
        $Body['cluster_id'] = $ClusterId
        Try {
            $BodyText = $Body | ConvertTo-Json -Depth 10
            Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/clusters/delete" -Headers $Headers
        }
        Catch {
            Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
            Write-Output $_.Exception
            Write-Error $_.ErrorDetails.Message
            Return
        }
    }
}