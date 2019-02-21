<#

.SYNOPSIS
    Add Databricks user or group to a group.

.DESCRIPTION
    This command allows to add existing user or group to a group.

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Member
    Name of an exsisting user or a group. 

.PARAMETER Parent
    Name of an existing parent group.

.EXAMPLE 
C:\PS> Add-DatabricksUserToGroup -BearerToken $BearerToken -Region $Region -Name "user@yourdomain.com" -Parent "developers"

This example adds user user@yourdomain.com to "developers" group 

.NOTES
    Author: Tadeusz Balcer

#>

Function Add-DatabricksMemberToGroup
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$Member,
        [parameter(Mandatory=$true)][string]$Parent
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    Try
    {
        $groups = Get-DatabricksGroups -BearerToken $BearerToken -Region $Region
        If ($groups.Contains($Member)) 
        {
            $body = '{"group_name": "' + $Member + '", "parent_name": "' + $Parent + '"   }'    
        }
        Else 
        {
            $body = '{"user_name": "' + $Member + '", "parent_name": "' + $Parent + '"   }'
        }

        Invoke-RestMethod -Method Post -Body $body -Uri "https://$Region.azuredatabricks.net/api/2.0/groups/add-member" -Headers @{Authorization = $InternalBearerToken} -OutFile $OutFile
        Write-Verbose "User $UserName added to $Parent group"
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
