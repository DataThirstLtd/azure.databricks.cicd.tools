<#
.SYNOPSIS
MKDir in DBFS

.DESCRIPTION
Create a new folder in DBFS. Will do nothing if it already exists.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER FolderPath
Folder path to create. Must be from root so starts with /.
Will create full path if parent does not exist.

.EXAMPLE
C:\PS> Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region -FolderPath /test

Creates a folder called "test" off root.

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>
Function Add-DatabricksDBFSFolder {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [Parameter(Mandatory = $true)][string]$FolderPath
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    $uri ="https://$Region.azuredatabricks.net/api/2.0/dbfs/mkdirs"

    $Body = @{"path"= $FolderPath}

    $BodyText = $Body | ConvertTo-Json -Depth 10

    Write-Verbose "Request Body: $BodyText"
    Invoke-RestMethod -Uri $uri -Body $BodyText -Method 'POST' -Headers @{Authorization = $InternalBearerToken}
}
