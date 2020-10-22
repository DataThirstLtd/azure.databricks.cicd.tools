<#
.SYNOPSIS
Removes a Databricks notebook or folder from the workspace

.DESCRIPTION
Removes a Databricks notebook or folder from the workspace

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Path
Absolute path - wildcards not accepted

.PARAMETER Recursive
Switch defaults to $False, recurseivly delete everything in folder

.EXAMPLE
PS C:\> Remove-DatabricksNotebook -BearerToken $BearerToken -Region $Region -Path '/Shared/Bob/Test1' -Recursive

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Remove-DatabricksNotebook {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,    
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$Path,
        [parameter(Mandatory = $false)][switch]$Recursive,
        [parameter(Mandatory = $false)][int]$SleepInMs = 200
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters
    
    $body = @{}
   
    If ($PSBoundParameters.ContainsKey('Recursive')) {
        $Body['recursive'] = $true
    }

    $Body['path'] = $Path

    $BodyText = $Body | ConvertTo-Json -Depth 10
    try {
        Invoke-RestMethod -Uri "$global:DatabricksURI/api/2.0/workspace/delete" -Body $BodyText -Method 'POST' -Headers $Headers
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq "TooManyRequests") {
            Write-Verbose "Too many requests, trying once more"
            Start-Sleep -Milliseconds $SleepInMs
            Invoke-RestMethod -Uri "$global:DatabricksURI/api/2.0/workspace/delete" -Body $BodyText -Method 'POST' -Headers $Headers
        }
    }
}