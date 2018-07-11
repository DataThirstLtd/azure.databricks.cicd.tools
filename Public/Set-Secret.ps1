Function Set-Secret
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

    Add-SecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName

    $body = '{ "scope": "' + $ScopeName + '", "key": "' + $SecretName + '", "string_value": "' + $SecretValue + '"}'

    Invoke-RestMethod -Method Post -Body $body -Uri "https://$Region.azuredatabricks.net/api/2.0/secrets/put" -Headers @{Authorization = $InternalBearerToken}
    Write-Output "Secret $SecretName Set"
}