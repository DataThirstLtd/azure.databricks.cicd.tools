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
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$Path,
        [parameter(Mandatory = $false)][switch]$Recursive
        )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")
    
    $body = @{}
   
    If ($PSBoundParameters.ContainsKey('Recursive')) {
        $Body['recursive'] = $true
    }

    $Body['path'] = $Path
    Try {
        $BodyText = $Body | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "https://$Region.azuredatabricks.net/api/2.0/workspace/delete" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Output $_.Exception
        Write-Error $_.ErrorDetails.Message
        Return
    }
}