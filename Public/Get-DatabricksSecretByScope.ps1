<#
.SYNOPSIS
List all Secrets By Scope

.DESCRIPTION
List all Secrets of a scope. Or search for one secret by key.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ScopeName
Return secrets under this scope.

.PARAMETER SecretKey
Optional. Search for a specific secret by key


.EXAMPLE
PS C:\> Get-DatabricksSecretByScope -BearerToken $BearerToken -Region $Region -ScopeName "MyScope"

PS C:\> Get-DatabricksSecretByScope -BearerToken $BearerToken -Region $Region -ScopeName "MyScope" -Secretkey "secretName"

.NOTES
Author: Richie Lee / @richiebzzzt 

#>  
Function Get-DatabricksSecretByScope { 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$ScopeName,
        [parameter(Mandatory = $false)][string]$SecretKey
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters
    
    Try {
        $Secrets = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/secrets/list?scope=$ScopeName" -Headers $Headers
    }
    Catch {
        $err = $_.ErrorDetails.Message
        if ($err.Contains('RESOURCE_DOES_NOT_EXIST')) {
            Write-Verbose $err
        }
        else {
            Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
            Write-Error $err
        }
    }

    if ($SecretKey){
        Return ($Secrets.secrets | where-object {$_.key -eq "$SecretKey"})
    }
    else{
        return $Secrets.secrets
    }
}
    
