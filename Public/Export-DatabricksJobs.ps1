<#
.SYNOPSIS
Exports DataBricks Jobs and Saves as json.

.DESCRIPTION
Exports Databricks Jobs and saves as json. Use '-settingsonly' in order for them to be published via Add-DatabricksNotebookJob and using $jobSettings

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER JobIds
Array of job IDs that you want to export

.PARAMETER SettingsOnly
Will save only the settings of the job that are required to create the job via the API.

.PARAMETER LocalOutputPath
Local directroy to save json files.

.EXAMPLE

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#> 
Function Export-DatabricksJobs {  
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)][string]$BearerToken,    
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][int[]] $jobIds,
        [parameter(Mandatory = $true)][string]$LocalOutputPath,
        [parameter(Mandatory = $false)][switch]$SettingsOnly
    )

    foreach ($jobId in $jobIds) {   
        if ($PSBoundParameters.ContainsKey('SettingsOnly') -eq $true) {
            $job = Get-DatabricksJob -BearerToken $BearerToken -Region $config.Region -JobId $jobId -SettingsOnly -Verbose
            $jobAsJson = $job | ConvertTo-Json
            $jobFileName = ($job.name -replace '[\W]', '_') + '.json'
        }
        else {
            $job = Get-DatabricksJob -BearerToken $BearerToken -Region $config.Region -JobId $jobId -Verbose
            $jobAsJson = $job | ConvertTo-Json
            $jobFileName = ($job.settings.name -replace '[\W]', '_') + '.json'
        }
        $LocalExportPath = Join-Path $LocalOutputPath $jobFileName
        Write-Verbose "Exporting job to $LocalExportPath"
        New-Item -force -path $LocalExportPath -value $jobAsJson -type file | out-null
    }
}