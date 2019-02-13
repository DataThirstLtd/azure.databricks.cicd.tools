<#

.SYNOPSIS
    Create a user group in a Databricks instance.

.DESCRIPTION
    Create a user group in a Databricks instance.

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER GroupName
    Name for the new group.

.EXAMPLE 
C:\PS> Add-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName acme

This example creates a group called acme

.NOTES
    Author: Tadeusz Balcer

#>


Function Add-DatabricksGroup
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$GroupName
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")
    

    Try
    {
        $body = '{"group_name": "' + $GroupName + '"  }'

        Invoke-RestMethod -Method Post -Body $body -Uri "https://$Region.azuredatabricks.net/api/2.0/groups/create" -Headers @{Authorization = $InternalBearerToken}
        Write-Output "Group $GroupName has been created"
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

# Command was renamed to align prefixes
New-Alias -Name Add-Group -Value Add-DatabricksGroup