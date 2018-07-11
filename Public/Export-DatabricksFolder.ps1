Function Export-DatabricksFolder
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$ExportPath,
        [parameter(Mandatory=$false)][string]$LocalOutputPath
    )

<#
.SYNOPSIS
Pulls the contents of a Databricks folder (and subfolders) locally so that they can be committed to a repo

.DESCRIPTION
Pulls the contents of a Databricks folder (and subfolders) locally so that they can be committed to a repo

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ExportPath
The Databricks folder to export, for example /Shared or /Users/simon@datathirst.net/myfolder - must start with /

.PARAMETER LocalOutputPath
Path to your repo/local you would like to export the scripts to

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

    if ($LocalOutputPath -ne [System.IO.Path]::GetFullPath($LocalOutputPath)){
        $LocalOutputPath = Join-Path (Get-Location) $LocalOutputPath
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)

    $outJSON = Get-FolderContents $ExportPath $Region $InternalBearerToken
    Get-Notebooks $outJSON $ExportPath $Region $InternalBearerToken $LocalOutputPath

}
