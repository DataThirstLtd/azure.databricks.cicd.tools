<#
.SYNOPSIS
Retrieve Job Settings

.DESCRIPTION
Retrieves job Setting by ID
.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER JobId
The ID of the job

.PARAMETER SettingsOnly
Returnso nly the settings. useful if you want to export the settings of a job to source control.

.EXAMPLE
Get Job
PS C:\> Get-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId "MyTestJob"

Get Job With Settings Only
PS C:\> Get-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId "MyTestJob" -SettingsOnly

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Get-DatabricksJob
{ 
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$JobId,
        [parameter(Mandatory = $false)][switch]$SettingsOnly
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    Try {
        $Job = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/jobs/get?job_id=$JobId" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    if($PSBoundParameters.ContainsKey('SettingsOnly') -eq $false)  {
        Write-Verbose "Returning Job $($job.settings.name)"
        Return $Job
    }
    else{
        Write-Verbose "Returning Job Settings for $($Job.settings.name)"
        Return $job.Settings
    }

}
    