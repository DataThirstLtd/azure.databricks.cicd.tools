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
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $false)][string]$Path
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    Try {
        $Files = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/dbfs/list?path=$Path" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return $Files.files
}
    