<#
.SYNOPSIS
    Upload a file or folder of files from your local filesystem into DBFS.

.DESCRIPTION
    Upload a file or folder of files to DBFS. Supports exact path or pattern matching. Target folder in DBFS does not need to exist - they will be created as needed.
    Existing files will be overwritten.
    Use this as part of CI/CD pipeline to publish your code & libraries.

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER LocalRootFolder
    Path to file(s) to upload, can be relative. Note that subfolders are recursed always.
    
.PARAMETER FilePattern
    File pattern to match. Examples: *.py  *.*  ProjectA*.*

.PARAMETER TargetLocation
    Target folder in DBFS should start /.
    Does not need to exist.

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

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
        $FileTarget = $FileTarget.Replace("\","/")
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