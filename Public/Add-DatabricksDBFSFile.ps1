Function Add-DatabricksDBFSFile {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$LocalRootFolder,
        [parameter(Mandatory = $true)][string]$FilePattern,
        [parameter(Mandatory = $true)][string]$TargetLocation
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")
    $uri ="https://$Region.azuredatabricks.net/api/2.0/dbfs/put"
    Push-Location
    Set-Location $LocalRootFolder

    $AllFiles = Get-ChildItem -Filter $FilePattern -Recurse -File

    Foreach ($f in $AllFiles){
        Write-Verbose "Replacing CRLF with LF for $f"
        $text = [IO.File]::ReadAllText($f) -replace "`r`n", "`n"
        [IO.File]::WriteAllText($f, $text)

        Write-Verbose "Encoding $f to BASE64"
        $BinaryContents = [System.IO.File]::ReadAllBytes($f)
        $EncodedContents = [System.Convert]::ToBase64String($BinaryContents)

        $FileTarget = (Join-Path $TargetLocation (Resolve-Path $f -Relative))
        $FileTarget = $FileTarget.Replace("/./","/")
        
        $Body = @{"contents"=$EncodedContents}
        $Body['path'] = $FileTarget
        $Body['overwrite'] = "true"
    
        $BodyText = $Body | ConvertTo-Json -Depth 10
        Write-Output "Pushing file $($f.FullName) to $FileTarget to REST API: $uri"
        Invoke-RestMethod -Uri $uri -Body $BodyText -Method 'POST' -Headers @{Authorization = $InternalBearerToken}
    }
    Pop-Location
}