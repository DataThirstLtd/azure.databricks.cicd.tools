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
    Path to file(s) to upload, can be relative or full. Note that subfolders are recursed always.
    
.PARAMETER FilePattern
    File pattern to match. Examples: *.py  *.*  ProjectA*.*

.PARAMETER TargetLocation
    Target folder in DBFS should start /.
    Does not need to exist.

.EXAMPLE 
    C:\PS> Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder "Samples" -FilePattern "Test.jar"  -TargetLocation '/test' -Verbose
        
    This example uploads a single file called Test.jar which is a relative path to your working directory.

.EXAMPLE 
    C:\PS> Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder Samples/DummyNotebooks -FilePattern "*.py"  -TargetLocation '/test2/' -Verbose

    This example uploads a folder of py files

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

Function Add-DatabricksDBFSFile {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,    
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$LocalRootFolder,
        [parameter(Mandatory = $true)][string]$FilePattern,
        [parameter(Mandatory = $true)][string]$TargetLocation
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $Headers = GetHeaders $PSBoundParameters
    
    $size = 1200000
    $LocalRootFolder = Resolve-Path $LocalRootFolder
    Write-Verbose $LocalRootFolder
    Push-Location
    Set-Location $LocalRootFolder

    $AllFiles = Get-ChildItem -Filter $FilePattern -Recurse -File

    Foreach ($f in $AllFiles){
        $f = Resolve-Path $f.FullName

        $BinaryContents = [System.IO.File]::ReadAllBytes($f)
        $EncodedContents = [System.Convert]::ToBase64String($BinaryContents)

        Write-Verbose "TargetLocation: $TargetLocation"
        $FileTarget = (Join-Path $TargetLocation (Resolve-Path $f -Relative))
        
        $FileTarget = $FileTarget.Replace("\","/")
        $FileTarget = $FileTarget.Replace("/./","/")

        Write-Verbose "FileTarget: $FileTarget"

        if ($EncodedContents.Length -gt $size) {
            $Body = @{'path' = $FileTarget}
            $Body['overwrite'] = "true"

            $BodyText = $Body | ConvertTo-Json -Depth 10
            $handle = Invoke-RestMethod -Uri "$global:DatabricksURI/api/2.0/dbfs/create" -Body $BodyText -Method 'POST' -Headers $Headers

            $i = 0
            While ($i -le ($EncodedContents.length-$size))
            {
                $part = $EncodedContents.Substring($i,$size)
                Add-DatabricksChunk -part $part -handle $handle.handle
                $i += $size
                Write-Verbose "Uploaded $i bytes"
            }
            $part = $EncodedContents.Substring($i)
            Add-DatabricksChunk -part $part -handle $handle.handle   

            $Body = @{"handle"= $handle.handle}
            $BodyText = $Body | ConvertTo-Json -Depth 10
            Invoke-RestMethod -Uri "$global:DatabricksURI/api/2.0/dbfs/close" -Body $BodyText -Method 'POST' -Headers $Headers
        }
        else
        {
            $Body = @{"contents"=$EncodedContents}
            $Body['path'] = $FileTarget
            $Body['overwrite'] = "true"    
            $BodyText = $Body | ConvertTo-Json -Depth 10
            Write-Verbose "Pushing file $($f.Path) to $FileTarget"
            Invoke-RestMethod -Uri "$global:DatabricksURI/api/2.0/dbfs/put" -Body $BodyText -Method 'POST' -Headers $Headers
        }
    }
    Pop-Location
}