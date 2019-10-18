<#
.SYNOPSIS
Delete a file or folder within DBFS

.DESCRIPTION
Delete a file or folder within DBFS. 

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Path
The Databricks DBFS folder to delete

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Remove-DatabricksDBFSItem
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $false)][string]$Path
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    
    $Body = @{}
    $Body['path'] = $Path
    $Body['recursive'] = 'true'

    $BodyText = $Body | ConvertTo-Json -Depth 10
    
    Try {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/dbfs/delete" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return 
}
    