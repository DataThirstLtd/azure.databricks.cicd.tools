<#
.SYNOPSIS
Get a listing of files and folders within DBFS

.DESCRIPTION
Get a listing of files and folders within DBFS 

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Path
The Databricks DBFS folder to list

.EXAMPLE
PS C:\> Get-DatabricksDBFSFolder -BearerToken $BearerToken -Region $Region -Path /test

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  
Function Get-DatabricksDBFSFolder
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $false)][string]$Path
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    
    Try {
        $Files = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/dbfs/list?path=$Path" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return $Files.files
}
    