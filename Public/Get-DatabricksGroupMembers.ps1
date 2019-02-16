<#
.SYNOPSIS
Get a list of members of a group.

.DESCRIPTION
Get a list of members of a group. If GroupName is not set, all Databricks users will be returned.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER GroupName
Name of the group for which you want to list members. If not provided, all Databricks users will be returned.

.EXAMPLE
PS C:\> Get-DatabricksGroupMembers -BearerToken $BearerToken -Region $Region -GroupName acme

.NOTES
Author: Tadeusz Balcer.

#> 

Function Get-DatabricksGroupMembers
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$GroupName
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    Try {
        $Members = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/groups/list-members?group_name=$GroupName" -Headers @{Authorization = $InternalBearerToken}
        Return $Members.members
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
}

New-Alias -Name Get-GroupMembers -Value Get-DatabricksGroupMembers
    