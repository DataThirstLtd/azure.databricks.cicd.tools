Function Add-DatabricksFolder {    
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$Path
    ) 

    $Headers = GetHeaders $PSBoundParameters
    $body = '{"path": "' + $Path + '"}'

    Try
    {
        Invoke-RestMethod -Method Post -Body $body -Uri "$global:DatabricksURI/api/2.0/workspace/mkdirs" -Headers $Headers
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