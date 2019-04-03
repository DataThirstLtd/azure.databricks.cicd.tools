<#
.SYNOPSIS
List all Secret Scopes

.DESCRIPTION
List all Secret Scopes. Or search for one

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ScopeName
Optional. Search for a specific scope by name


.EXAMPLE
PS C:\> Get-DatabricksSecretScopes -BearerToken $BearerToken -Region $Region -ScopeName "MyScope"

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Get-DatabricksSecretScopes
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $false)][string]$ScopeName
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    
    Try {
        $Scopes = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/secrets/scopes/list" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    if ($ScopeName){
        Return ($Scopes.scopes | where-object {$_.name -eq "$ScopeName"})
    }
    else{
        return $Scopes.scopes
    }
}
    