Function Add-DatabricksLibrary {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [Parameter(Mandatory = $true)][ValidateSet('jar','egg','maven','pypi','cran')][string]$LibraryType,
        [parameter(Mandatory = $true)][string]$LibrarySettings,
        [parameter(Mandatory = $true)][string]$ClusterId
    ) 
<#
.SYNOPSIS
Installs a library to a Databricks cluster.

.DESCRIPTION
Attempts install of library. Note you must check if the install completes successfully as the install
happens async. See Get-DatabricksLibraries.
Also note that libraries installed via the API do not show in UI. Again see Get-DatabricksLibraries. This
is a known Databricks issue which maybe addressed in the future.
Note the API does not support the auto install to all clusters option as yet.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER LibraryType
Spark version for cluster. Example: 4.0.x-scala2.11
See Get-DatabricksSparkVersions
    
.PARAMETER LibrarySettings
Type of worker for cluster. Example: Standard_D3_v2
See Get-DatabricksNodeTypes

.PARAMETER ClusterId
The cluster to install the library to. Note that the API does not support auto installing to
all clusters. See Get-DatabricksClusters. 

.EXAMPLE
$ClusterId = (Get-DatabricksClusters -BearerToken $BearerToken -Region $Region).cluster_id[0]
$Settings = 'dbfs:/mnt/libraries/library.jar'

Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region `
    -LibraryType "jar" -LibrarySettings $Settings `
    -ClusterId $ClusterId

.EXAMPLE
$ClusterId = (Get-DatabricksClusters -BearerToken $BearerToken -Region $Region).cluster_id[0]
$Settings = 'simplejson'

Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region `
    -LibraryType "pypi" -LibrarySettings $Settings `
    -ClusterId $ClusterId

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    $uri ="https://$Region.azuredatabricks.net/api/2.0/libraries/install"

    $Body = @{"cluster_id"=$ClusterId}

    if (($LibrarySettings -notcontains '{') -and ($LibraryType -eq "pypi")) {
        #Pypi and only string passed - try as simple name
        Write-Verbose "Converting to pypi JSON request"
        $LibrarySettings = '{package: "' + $LibrarySettings + '"}'
    }

    if ($LibrarySettings -contains '{'){
        # Settings are JSON else assume String (name of library)
        Write-Verbose "Request is in JSON"
        $Libraries = @()
        $Library = @{}
        $Library[$LibraryType]= ($LibrarySettings | ConvertFrom-Json)
        $Libraries += $Library
        $Body['libraries'] = $Libraries
    }
    else {
        Write-Verbose "Request is a string"
        $Libraries = @()
        $Library = @{}
        $Library[$LibraryType]= $LibrarySettings
        $Libraries += $Library
        $Body['libraries'] = $Libraries
    }

    $BodyText = $Body | ConvertTo-Json -Depth 10

    Write-Verbose "Request Body: $BodyText"
    Write-Output "Installing library $LibraryType with setting $LibrarySettings to REST API: $uri"
    Invoke-RestMethod -Uri $uri -Body $BodyText -Method 'POST' -Headers @{Authorization = $InternalBearerToken}
}