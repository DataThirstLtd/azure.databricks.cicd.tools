<#
.SYNOPSIS
Get a list of Libraries and thier statuses for a Databricks cluster

.DESCRIPTION
Get a list of Libraries and thier statuses for a Databricks cluster

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ClusterId
ClusterId for existing Databricks cluster. Does not need to be running. See Get-DatabricksClusters.

.EXAMPLE
PS C:\> Get-DatabricksLibraries -BearerToken $BearerToken -Region $Region -ClusterId 'Bob-1234'

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Get-DatabricksLibraries
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$ClusterId
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    $Uri = "https://$Region.azuredatabricks.net/api/2.0/libraries/cluster-status?cluster_id=$ClusterId"

    Try {
        $Libraries = Invoke-RestMethod -Method Get -Uri $Uri -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return $Libraries.library_statuses
}
    