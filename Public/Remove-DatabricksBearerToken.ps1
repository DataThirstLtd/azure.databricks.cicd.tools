<#
.SYNOPSIS
Deletes Bearer Token

.DESCRIPTION
Deletes Bearer Token

.PARAMETER TokenId
Token to delete

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Remove-DatabricksBearerToken {  
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)] [string]$TokenId
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Body = @{}
    $Body['token_id']=$TokenId

    Return Invoke-DatabricksAPI  -Method POST -API "api/2.0/token/delete" -Body $Body
}