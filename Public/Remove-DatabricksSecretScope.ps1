<#
.SYNOPSIS
Delete a Secret Scope by Name

.DESCRIPTION
Delete a Secret Scope by Name

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ScopeName
Name of the scope to remove, will not error if it does not exist

.PARAMETER RemoveEmptyOnly
Switch that if included will check if scope is not empty.

.EXAMPLE
PS C:\> Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "MyScope"

PS C:\> Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "MyScope" -RemoveEmptyOnly

.NOTES
Author: Simon D'Morias / Data Thirst Ltd
#>  

Function Remove-DatabricksSecretScope { 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$ScopeName,
        [parameter(Mandatory = $false)][switch]$RemoveEmptyOnly

    ) 
    $secrets = Get-DatabricksSecretByScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName

    If ($PSBoundParameters.ContainsKey('RemoveEmptyOnly') -eq $true) {
        if ($secrets.count -gt 0) {
            Write-Output "Scope $ScopeName has $($secrets.count) secret and is not empty!"
            Throw
        }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 

    $Body = @{}
    $Body['scope'] = $ScopeName
    $BodyText = $Body | ConvertTo-Json -Depth 10
    if ($secrets.count -gt 0) {
        $SecretNames = $secrets.key -join "`n"
        Write-Verbose "Following secrets will be deleted... `n $SecretNames"
    }
    Try {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/secrets/scopes/delete" -Headers $Headers
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

    Return 
}
    