<#
.SYNOPSIS
Get a listing of files and folders within a Workspace folder

.DESCRIPTION
Get a listing of files and folders within a Workspace folder

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Path
The Databricks workspace folder to list

.EXAMPLE
PS C:\> Get-DatabricksWorkspaceFolder -BearerToken $BearerToken -Region $Region -Path /Shared

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  
Function Get-DatabricksWorkspaceFolder
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $false)][string]$Path
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    

    $Response = Invoke-RestMethod -Method GET -Uri "$global:DatabricksURI/api/2.0/workspace/list?path=$Path" -Headers $Headers

    Return $Response.objects
}
    
