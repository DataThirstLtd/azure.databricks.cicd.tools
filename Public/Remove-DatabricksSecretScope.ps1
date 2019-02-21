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

.EXAMPLE
PS C:\> Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "MyScope"

.NOTES
Author: Simon D'Morias / Data Thirst Ltd
#>  

Function Remove-DatabricksSecretScope
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$ScopeName
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    $Body = @{}
    $Body['scope'] = $ScopeName

    $BodyText = $Body | ConvertTo-Json -Depth 10
    
    Try {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "https://$Region.azuredatabricks.net/api/2.0/secrets/scopes/delete" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        $err = $_.ErrorDetails.Message
        if ($err.Contains('RESOURCE_DOES_NOT_EXIST'))
        {
            Write-Verbose $err
        }
        else
        {
            Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
            Write-Error $err
        }
    }

    Return 
}
    