Function Add-DatabricksChunk([string]$part, [string]$InternalBearerToken, [string]$Region, $handle){
    $Body = @{"data"=$part}
    $Body['handle'] = $handle
    $BodyText = $Body | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Uri "https://$Region.azuredatabricks.net/api/2.0/dbfs/add-block" -Body $BodyText -Method 'POST' -Headers @{Authorization = $InternalBearerToken}
    Return
}