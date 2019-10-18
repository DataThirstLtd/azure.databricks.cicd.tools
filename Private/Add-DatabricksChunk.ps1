Function Add-DatabricksChunk([string]$part, $handle){
    $Body = @{"data"=$part}
    $Body['handle'] = $handle
    $BodyText = $Body | ConvertTo-Json -Depth 10

    $Headers = GetHeaders $null
    Invoke-RestMethod -Uri "$global:DatabricksURI/api/2.0/dbfs/add-block" -Body $BodyText -Method 'POST' -Headers $Headers
    Return
}