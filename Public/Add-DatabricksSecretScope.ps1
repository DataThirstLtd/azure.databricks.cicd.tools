<#

.SYNOPSIS
    Create a scope to store Databricks secret in.

.DESCRIPTION
    Create a scope to store Databricks secret in. Note the the Set-DatabricksSecret command creates the scope if it does not exist.
    Note that from version 1.9 all scopes are created with a generic permission to allow all users to access it.

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ScopeName
    Name for the scope - do not include spaces or special characters.

.EXAMPLE 
C:\PS> Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "Test1"

This example creates a scope called Test1

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>


Function Add-DatabricksSecretScope
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$ScopeName
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")
    $body = '{"scope": "' + $ScopeName + '", "initial_manage_principal": "users"}'

    Try
    {
        Invoke-RestMethod -Method Post -Body $body -Uri "https://$Region.azuredatabricks.net/api/2.0/secrets/scopes/create" -Headers @{Authorization = $InternalBearerToken} -OutFile $OutFile
        Write-Output "Secret Scope $ScopeName created"
    }
    Catch
    {
        $err = $_.ErrorDetails.Message
        if ($err.Contains('already exists'))
        {
            Write-Verbose $err
        }
        else
        {
            throw
        }
    }

}

# Command was renamed to align prefixes
New-Alias -Name Add-SecretScope -Value Add-DatabricksSecretScope