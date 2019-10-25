<#
.SYNOPSIS
Creates a new Bearer Token

.DESCRIPTION
Creates a new Bearer Token

.PARAMETER LifetimeSeconds
Number of seconds a token should be valid for. If ommitted the token will not expire.

.PARAMETER Comment
Optional comment

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function New-DatabricksBearerToken {  
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $false)] [int]$LifetimeSeconds,
        [parameter(Mandatory = $false)] [string]$Comment
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Body = @{}
    if ($LifetimeSeconds){$Body['lifetime_seconds']=$LifetimeSeconds}
    if ($Comment){$Body['comment']=$Comment}
    
    Return Invoke-DatabricksAPI  -Method POST -API "api/2.0/token/create" -Body $Body
}