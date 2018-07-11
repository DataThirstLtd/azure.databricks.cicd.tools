Function Add-DatabricksFolder {    
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,    
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$Path
    ) 

    $InternalBearerToken = Format-BearerToken($BearerToken)
    $body = '{"path": "' + $Path + '"}'

    Try
    {
        Invoke-RestMethod -Method Post -Body $body -Uri "https://$Region.azuredatabricks.net/api/2.0/workspace/mkdirs" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch
    {
        if ($_.ErrorDetails.Message.Contains('already exists') -eq $true)
        {
            Write-Verbose "Folder already exists"
        }
        else
        {
            Write-Error $_.ErrorDetails.Message
            break
        }
    }
}