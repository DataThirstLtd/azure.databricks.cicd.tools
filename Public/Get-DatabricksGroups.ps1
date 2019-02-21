<#
.SYNOPSIS
Get a list of groups.

.DESCRIPTION
Get a list of groups.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.EXAMPLE
PS C:\> Get-DatabricksGroups -BearerToken $BearerToken -Region $Region

.NOTES
Author: Tadeusz Balcer.

#> 

Function Get-DatabricksGroups
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    Try {
        $Groups = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/groups/list" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        if ($_.Exception.Response -eq $null) {
            Write-Error $_.Exception.Message
        } else {
            Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
            Write-Error $_.ErrorDetails.Message   
        }
    }

    Return $Groups.group_names
}

    