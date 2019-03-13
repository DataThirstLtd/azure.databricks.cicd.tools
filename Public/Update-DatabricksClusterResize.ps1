<#
.SYNOPSIS
Resize number of workers in a Databricks cluster

.DESCRIPTION
Resize number of workers in a Databricks cluster

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER MinNumberOfWorkers
Min number of workers for cluster that will run the job. If the same as $MaxNumberOfWorkers autoscale is disabled.

.PARAMETER MaxNumberOfWorkers
Max number of workers for cluster that will run the job. If the same as $MinNumberOfWorkers autoscale is disabled.

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>
Function Update-DatabricksClusterResize
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$ClusterId,
        [parameter(Mandatory = $true)][int]$MinNumberOfWorkers,
        [parameter(Mandatory = $true)][int]$MaxNumberOfWorkers
    ) 
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    $Body = @{}

    $Body['cluster_id'] = $ClusterId

    If ($MinNumberOfWorkers -eq $MaxNumberOfWorkers){
        $Body['num_workers'] = $MinNumberOfWorkers
    }
    else {
        $Body['autoscale'] = @{"min_workers"=$MinNumberOfWorkers;"max_workers"=$MaxNumberOfWorkers}
    }

    Try {
        $BodyText = $Body | ConvertTo-Json -Depth 10
        Write-Verbose $BodyText
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/clusters/resize" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

}
    