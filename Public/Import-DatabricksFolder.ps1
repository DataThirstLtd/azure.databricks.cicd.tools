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

.EXAMPLE
PS C:\> Import-DatabricksFolder -BearerToken $BearerToken -Region $Region -LocalPath 'Samples\DummyNotebooks' -DatabricksPath 'Shared\ProjectX'

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Import-DatabricksFolder
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$BearerToken,
        [parameter(Mandatory=$true)][string]$Region,
        [parameter(Mandatory=$true)][string]$LocalPath,
        [parameter(Mandatory=$true)][string]$DatabricksPath
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    Push-Location
    $Files = Get-ChildItem $LocalPath -Recurse -Attributes !D
    Set-Location $LocalPath
    
    ForEach ($FileToPush In $Files)
    {
        $Path = $FileToPush.DirectoryName
        $LocalPath = $LocalPath.Replace("/","\")

        if ($FileToPush.DirectoryName -ne (Get-Location).Path) {
            $FolderFromTargetRoot = (Resolve-Path ($FileToPush.DirectoryName) -Relative)
            $Path = Join-Path $DatabricksPath $FolderFromTargetRoot
        }
        else{
            $Path = $DatabricksPath
        }
        
        $Path = $Path.Replace("\","/")
        $Path = $Path.Replace("/./","/")

        # Create folder in Databricks
        Add-DatabricksFolder -Bearer $BearerToken -Region $Region -Path $Path
        Write-Verbose "Path: $Path"

        $BinaryContents = [System.IO.File]::ReadAllBytes($FileToPush.FullName)
        $EncodedContents = [System.Convert]::ToBase64String($BinaryContents)
        $TargetPath = $Path + '/'+ $FileToPush.BaseName

        $Body = @{}
        $Body['content'] = $EncodedContents
        $Body['path'] = $TargetPath
        $Body['overwrite'] = "true"
        switch ($FileToPush.Extension){
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

        if($null -eq $Body['format'])
        {
            Write-Warning "File $FileToPush has an unknown extension - skipping file"
        }
        else{
            Write-Verbose "Pushing file $FileToPush to $TargetPath"
            Invoke-RestMethod -Uri "https://$Region.azuredatabricks.net/api/2.0/workspace/import" -Body $BodyText -Method 'POST' -Headers @{Authorization = $InternalBearerToken}
        }
    }

    Pop-Location
}
