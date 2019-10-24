<#
.SYNOPSIS
Delete a Databricks secret.

.DESCRIPTION
Delete a Databricks secret.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ScopeName
Name for the scope - do not include spaces or special characters.

.PARAMETER SecretName
Name of the Secret to delete

.EXAMPLE 
C:\PS> Remove-DatabricksSecret -BearerToken $BearerToken -Region $Region -ScopeName "Test1" -SecretName "Test"

This example removes a secret called Test in Scope Test1

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Remove-DatabricksSecret
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$false)][string]$BearerToken,
        [parameter(Mandatory=$false)][string]$Region,
        [parameter(Mandatory=$true)][string]$ScopeName,
        [parameter(Mandatory=$true)][string]$SecretName
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $Headers = GetHeaders $PSBoundParameters
    
    $body = @{}
    $body['scope'] = $ScopeName
    $body['key'] = $SecretName

    $BodyText = $Body | ConvertTo-Json -Depth 10

    Try
    {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/secrets/delete" -Headers $Headers
    }
    Catch
    {
        $err = $_.ErrorDetails.Message
        if ($err.Contains('exist'))
        {
            Write-Verbose $err
        }
        else
        {
            throw
        }
    }

}
