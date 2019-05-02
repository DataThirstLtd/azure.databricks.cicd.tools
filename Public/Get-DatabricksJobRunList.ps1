<#
.SYNOPSIS
Returns a list of runs for a given job

.DESCRIPTION
Returns a list of runs for a given job

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER JobId
Required.

.PARAMETER Limit
Int - max number of job runs to return

.EXAMPLE
PS C:\> Get-DatabricksJobRunList -BearerToken $BearerToken -Region $Region -JobId 10

Returns all clusters

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksJobRunList
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$JobId,
        [parameter(Mandatory = $false)][int]$Limit=10
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    Try {
        $Output = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/jobs/runs/list?job_id=$JobId&limit=$Limit" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    return $Output

}
    