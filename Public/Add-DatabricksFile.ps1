Function Add-DatabricksFile {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$LocalFile,
        [parameter(Mandatory = $true)][string]$TargetLocation
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    if (!(Test-Path $LocalFile)){
        Write-Error "File $LocalFile does not exist"
        Return
    }
    $LocalFile = Resolve-Path $LocalFile
    Write-Output $LocalFile
    $filename = Split-path -leaf $LocalFile

    $uri ="https://$Region.azuredatabricks.net/api/2.0/dbfs/put"

    Write-Verbose "Replacing CRLF with LF for $LocalFile"
    $text = [IO.File]::ReadAllText($LocalFile) -replace "`r`n", "`n"
    [IO.File]::WriteAllText($LocalFile, $text)

    Write-Verbose "Encoding $LocalFile to BASE64"
    $BinaryContents = [System.IO.File]::ReadAllBytes($LocalFile)
    $EncodedContents = [System.Convert]::ToBase64String($BinaryContents)

    $targetPath = "$TargetLocation/$filename"
    
    $Body = @{"contents"=$EncodedContents}
    $Body['path'] = $targetPath
    $Body['overwrite'] = "true"
   
    $BodyText = $Body | ConvertTo-Json -Depth 10
    Write-Output "Pushing file $File to $TargetPath to REST API: $uri"
    Invoke-RestMethod -Uri $uri -Body $BodyText -Method 'POST' -Headers @{Authorization = $InternalBearerToken}
}