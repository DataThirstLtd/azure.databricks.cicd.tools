<#

.SYNOPSIS
    Create a scope to store Databricks secret in.

.DESCRIPTION
    Create a scope to store Databricks secret in. Note the the Set-DatabricksSecret command creates the scope if it does not exist.
    Populate KeyVaultResourceId to create a scope from a Key Vault

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ScopeName
    Name for the scope - do not include spaces or special characters.

.PARAMETER KeyVaultResourceId
    Resource ID for a Key Vault to attach this scope to an Azure Key Vault. Should be in the URI form, 
    see the properties blade of your Key Vault and copy the RESOURCE ID
    THIS IS IN PREVIEW AND NOT OFFICALLY SUPPORTED BY DATABRICKS YET

.PARAMETER AllUserAccess
    By default only the user creating the scope has access to secrets. When you set this flag all users will
    have access. Hopefully better permissions controls will come.

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
        [parameter(Mandatory=$false)][string]$BearerToken,
        [parameter(Mandatory=$false)][string]$Region,
        [parameter(Mandatory=$true)][string]$ScopeName,
        [parameter(Mandatory=$false)][string]$KeyVaultResourceId,
        [parameter(Mandatory=$false)][switch]$AllUserAccess
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $Headers = GetHeaders $PSBoundParameters
    
    $body = @{}
    $body['scope'] = $ScopeName

    if ($AllUserAccess){$body['initial_manage_principal'] = "users"}

    # Key Vault backed Scope (This is in preview only)
    if ($PSBoundParameters.ContainsKey('KeyVaultResourceId')){
        $kv = @{}
        $kv['resource_id'] = $KeyVaultResourceId
        $LastPart = ($KeyVaultResourceId.split('/')[-1]).toLower()
        $kv['dns_name'] = "https://$LastPart.vault.azure.net/"
        
        $body['scope_backend_type'] = 'AZURE_KEYVAULT'
        $body['backend_azure_keyvault'] = $kv
    }
    
    $BodyText = $Body | ConvertTo-Json -Depth 10

    Try
    {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/secrets/scopes/create" -Headers $Headers
        Write-Verbose "Secret Scope $ScopeName created"
    }
    Catch
    {
        Write-Host $_
    }

}
