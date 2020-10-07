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

.PARAMETER AllUserAccess
    By default only the user creating the scope has access to secrets. When you set this flag all users will
    have access. Hopefully better permissions controls will come.

.EXAMPLE 
    C:\PS> Set-DatabricksSecret -BearerToken $BearerToken -Region $Region -ScopeName "Test1" -SecretName 'MySecretName' -SecretValue 'P@ssword'

    This example creates a scope called Test1 if it does not exist and a secret called MySecretName with a value of P@ssword.

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

Function Set-DatabricksSecret {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$ScopeName,
        [Parameter(Mandatory = $true)][string]$SecretName,
        [Parameter(Mandatory = $true)][string]$SecretValue,
        [parameter(Mandatory = $false)][switch]$AllUserAccess
    )

    $Headers = GetHeaders $PSBoundParameters
    

    if ($PSBoundParameters.ContainsKey('AllUserAccess') -eq $true) {
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName -AllUserAccess
    }
    else {
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName
    }

    $DataBricksSecret = @{
        scope        = $ScopeName
        key          = $SecretName
        string_value = $SecretValue
    }
    $body = $DataBricksSecret | ConvertTo-Json

    Invoke-RestMethod -Method Post -Body $body -Uri "$global:DatabricksURI/api/2.0/secrets/put" -Headers $Headers
    Write-Output "Secret $SecretName Set"
}


