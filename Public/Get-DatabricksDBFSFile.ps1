<#
.SYNOPSIS
Get a listing of files and folders within DBFS

.DESCRIPTION
Get a listing of files and folders within DBFS 

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER DBFSFile
The Databricks DBFS file to download

.PARAMETER TargetFile
Local file to download to

.EXAMPLE
PS C:\> Get-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -DBFSFile /test/config.txt -TargetFile ./output/config.txt

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 
#>  

Function Get-DatabricksDBFSFile {
    param(
        [parameter(Mandatory = $false)][string]$BearerToken,
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$DBFSFile,
        [parameter(Mandatory = $true)][string]$TargetFile
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    $size = 1048576

    $body = @{'path' = $DBFSFile }

    $chunkStart = 0
    [byte[]]$finalFile = $null
    $chunkEnd = $chunkStart + $size
    $bytesRead = $size

    while ($bytesRead -eq $size) {
        $body['offset'] = $chunkStart
        $body['length'] = $size
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $BodyText = $Body 
        }
        else {
            $BodyText = $Body | ConvertTo-Json -Depth 10
        }
        $chunk = Invoke-RestMethod -Uri "$global:DatabricksURI/api/2.0/dbfs/read" -Body $BodyText -Method 'GET' -Headers $Headers

        $finalFile += [Convert]::FromBase64String($chunk.data)

        $chunkStart = $chunkEnd + 1
        $chunkEnd = $chunkStart + $size
        $bytesRead = $chunk.bytes_read
    }
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        Set-Content -Path $TargetFile -Value $finalFile -Encoding Byte
    }
    else {
        Set-Content -Path $TargetFile -Value $finalFile -AsByteStream
    }
}
