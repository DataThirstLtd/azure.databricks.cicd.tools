Function Add-SecretScope
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$ScopeName
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $body = '{"scope": "' + $ScopeName + '"}'

    Try
    {
        Invoke-RestMethod -Method Post -Body $body -Uri "https://$Region.azuredatabricks.net/api/2.0/secrets/scopes/create" -Headers @{Authorization = $InternalBearerToken} -OutFile $OutFile
        Write-Output "Secret Scope $ScopeName created"
    }
    Catch
    {
        $err = $_.ErrorDetails.Message
        if ($err.Contains('already exists'))
        {
            Write-Verbose $err
        }
        else
        {
            throw
        }
    }

}