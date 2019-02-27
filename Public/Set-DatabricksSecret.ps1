<#

.SYNOPSIS
    Create a scope to store Databricks secret in.

.DESCRIPTION
    Create a scope to store Databricks secret in. Note the the Set-DatabricksSecret command creates the scope if it does not exist.

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ScopeName
    Name for the scope - do not include spaces or special characters.

.EXAMPLE 
    C:\PS> Set-DatabricksSecret -BearerToken $BearerToken -Region $Region -ScopeName "Test1" -SecretName 'MySecretName' -SecretValue 'P@ssword'

    This example creates a scope called Test1 if it does not exist and a secret called MySecretName with a value of P@ssword.

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

Function Set-DatabricksSecret
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$ScopeName,
        [Parameter(Mandatory=$true)][string]$SecretName,
        [Parameter(Mandatory=$true)][string]$SecretValue
    )

    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName

    $body = '{ "scope": "' + $ScopeName + '", "key": "' + $SecretName + '", "string_value": "' + $SecretValue + '"}'

    Invoke-RestMethod -Method Post -Body $body -Uri "https://$Region.azuredatabricks.net/api/2.0/secrets/put" -Headers @{Authorization = $InternalBearerToken}
    Write-Output "Secret $SecretName Set"
}


