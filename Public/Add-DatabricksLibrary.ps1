Function Add-DatabricksLibrary {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [Parameter(Mandatory = $true)][ValidateSet('jar','egg','maven','pypi','cran')][string]$LibraryType,
        [parameter(Mandatory = $true)][string]$LibrarySettings,
        [parameter(Mandatory = $true)][string]$ClusterId
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    $uri ="https://$Region.azuredatabricks.net/api/2.0/libraries/install"

    $Body = @{"cluster_id"=$ClusterId}
    $Body[$LibraryType] = $LibrarySettings
   
    $BodyText = $Body | ConvertTo-Json -Depth 10
    Write-Output "Pushing file $File to $TargetPath to REST API: $uri"
    Invoke-RestMethod -Uri $uri -Body $BodyText -Method 'POST' -Headers @{Authorization = $InternalBearerToken}
}