<#
.SYNOPSIS
Pushes the contents of a local folder (and subfolders) to Databricks

.DESCRIPTION
Use to deploy code from a repo

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER LocalPath
Path to your repo/local files that you would like to deploy to Databricks (should be in Source format)

.PARAMETER DatabricksPath
The Databricks folder to target

.PARAMETER Clean
Optional Switch. Delete the Databricks Workspace folder before copying files

.EXAMPLE
PS C:\> Import-DatabricksFolder -BearerToken $BearerToken -Region $Region -LocalPath 'Samples\DummyNotebooks' -DatabricksPath 'Shared\ProjectX'

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Import-DatabricksFolder {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$LocalPath,
        [parameter(Mandatory = $true)][string]$DatabricksPath,
        [parameter(Mandatory = $false)][switch]$Clean,
        [parameter(Mandatory = $false)][int]$SleepInMs = 200
    )
    $threadJobs = @()
    $throttleLimit = GetCpuCount

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    Push-Location
    $Files = Get-ChildItem $LocalPath -Recurse -Attributes !D
    Set-Location $LocalPath

    if ($Clean) {
        try {
            $ExistingFiles = Get-DatabricksWorkspaceFolder -Path $DatabricksPath
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq "NotFound") {
                Write-Verbose "# A 404 response is expected if the specified workspace does not exist in Databricks
                               # In this case, there will be no existing files to clean so the exception can be safely ignored"
            }
            else{
                Throw $_.Exception
            }
        }
        foreach ($f in $ExistingFiles) {
            if ($f.object_type -eq "DIRECTORY") {
                Write-Verbose "Removing directory $($f.path)"
                Remove-DatabricksNotebook -Path $f.path -Recursive -SleepInMs $SleepInMs 
            }
            else {
                Write-Verbose "Removing file $($f.path)"
                Remove-DatabricksNotebook -Path $f.path -SleepInMs $SleepInMs
            }
            Start-Sleep -Milliseconds $SleepInMs # Prevent 429 responses
        }
    }
    
    ForEach ($FileToPush In $Files) {
        $Path = $FileToPush.DirectoryName
        $LocalPath = $LocalPath.Replace("/", "\")

        if ($FileToPush.DirectoryName -ne (Get-Location).Path) {
            $FolderFromTargetRoot = (Resolve-Path ($FileToPush.DirectoryName) -Relative)
            $Path = Join-Path $DatabricksPath $FolderFromTargetRoot
        }
        else {
            $Path = $DatabricksPath
        }
        
        $Path = $Path.Replace("\", "/")
        $Path = $Path.Replace("/./", "/")

        # Create folder in Databricks
        Add-DatabricksFolder -Path $Path
        Write-Verbose "Path: $Path"
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $BinaryContents = [System.IO.File]::ReadAllBytes($FileToPush.FullName)
        }
        else {
            $BinaryContents = Get-Content $FileToPush.FullName -AsByteStream -ReadCount 0
        }

        # Handle empty files
        if ($BinaryContents) {
            $EncodedContents = [System.Convert]::ToBase64String($BinaryContents)
        }
        else {
            $EncodedContents = $null
        }
        $TargetPath = $Path + '/' + $FileToPush.BaseName

        $Body = @{ }
        $Body['content'] = $EncodedContents
        $Body['path'] = $TargetPath
        $Body['overwrite'] = "true"
        switch ($FileToPush.Extension) {
            ".py" {
                $Body['format'] = "SOURCE"
                $Body['language'] = "PYTHON"
            }

            ".scala" {
                $Body['format'] = "SOURCE"
                $Body['language'] = "SCALA"
            }

            ".r" {
                $Body['format'] = "SOURCE"
                $Body['language'] = "R"
            }

            ".sql" {
                $Body['format'] = "SOURCE"
                $Body['language'] = "SQL"
            }

            ".dbc" {
                $Body['format'] = "DBC"
            }

            ".ipynb" {
                $Body['format'] = "JUPYTER"
            }

            ".html" {
                $Body['format'] = "HTML"
            }

        }

        $BodyText = $Body | ConvertTo-Json -Depth 10

        if ($null -eq $Body['format']) {
            Write-Warning "File $FileToPush has an unknown extension - skipping file"
        }
        else {
            Write-Verbose "Pushing file $FileToPush to $TargetPath"
            $ProgressPreference = 'SilentlyContinue'
            $threadJobs += Start-ThreadJob -Name $fileToPush -ScriptBlock { Invoke-RestMethod -Uri $args[0] -Body $args[1] -Method 'POST' -Headers $args[2] } -ArgumentList "$global:DatabricksURI/api/2.0/workspace/import", $BodyText, $Headers -ThrottleLimit $throttleLimit
        }
    }
    
    if ($threadJobs.length -eq 0) {
        Pop-Location
        return
    }

    Wait-Job -Job $threadJobs | Out-Null
    $toThrow = $null
    foreach ($threadJob in $threadJobs) {
        $getState = Get-Job $threadJob.Name | Select-Object -Last 1
        if ($getState.State -eq 'Failed') {
            $toThrow = 1
            Write-Host ($threadJob.ChildJobs[0].JobStateInfo.Reason.Message) -ForegroundColor Red
        } 
        else {
            Write-Verbose "$($getState.Name) has $($getState.State)" 
        }
    }
    Pop-Location
    if ($null -ne $toThrow) {
        Write-Error "Oh dear one of the jobs has failed. Check the details of the jobs above."
    }
}