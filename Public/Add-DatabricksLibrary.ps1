<#
.SYNOPSIS
Installs a library to a Databricks cluster.

.DESCRIPTION
Attempts install of library. Note you must check if the install completes successfully as the install
happens async. See Get-DatabricksLibraries.
Also note that libraries installed via the API do not show in UI. Again see Get-DatabricksLibraries. This
is a known Databricks issue which maybe addressed in the future.
Note the API does not support the auto install to all clusters option as yet.
Cluster must not be in a terminated state (PENDING is ok).

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER LibraryType
egg, jar, pypi, whl, cran, maven
    
.PARAMETER LibrarySettings
Settings can by path to jar (starting dbfs), pypi name (optionally with repo), or egg

If jar, URI of the jar to be installed. DBFS and S3 URIs are supported. For example: { "jar": "dbfs:/mnt/databricks/library.jar" } or { "jar": "s3://my-bucket/library.jar" }. If S3 is used, make sure the cluster has read access on the library. You may need to launch the cluster with an IAM role to access the S3 URI.

If egg, URI of the egg to be installed. DBFS and S3 URIs are supported. For example: { "egg": "dbfs:/my/egg" } or { "egg": "s3://my-bucket/egg" }. If S3 is used, make sure the cluster has read access on the library. You may need to launch the cluster with an IAM role to access the S3 URI.

If whl, URI of the wheel or zipped wheels to be installed. DBFS and S3 URIs are supported. For example: { "whl": "dbfs:/my/whl" } or { "whl": "s3://my-bucket/whl" }. If S3 is used, make sure the cluster has read access on the library. You may need to launch the cluster with an IAM role to access the S3 URI. Also the wheel file name needs to use the correct convention. If zipped wheels are to be installed, the file name suffix should be .wheelhouse.zip.

If pypi, specification of a PyPI library to be installed. For example: { "package": "simplejson" }

If maven, specification of a Maven library to be installed. For example: { "coordinates": "org.jsoup:jsoup:1.7.2" }

If cran, specification of a CRAN library to be installed.

.PARAMETER ClusterId
The cluster to install the library to. Note that the API does not support auto installing to
all clusters. See Get-DatabricksClusters. 

.PARAMETER InputObject
Can take an object that is correctly formatted so that more than one library can be added.

{
  "cluster_id": "10201-my-cluster",
  "libraries": [
    {
      "jar": "dbfs:/mnt/libraries/library.jar"
    },
    {
      "egg": "dbfs:/mnt/libraries/library.egg"
    }
  ]
}

Output from Get-DatabricksLibraries can also be piped - 

$rcl = Get-DatabricksLibraries -ClusterId $clusterId -ReturnCluster
    for ($i = 0; $i -lt $rcl.library_statuses.Length; $i ++) {
        $rcl.library_statuses[$i].psobject.properties.remove('status')
        $rcl.library_statuses[$i].psobject.properties.remove('is_library_for_all_clusters')
    } 
    $LibsToAdd = [PSCustomObject]@{
        cluster_id     = $anotherClusterId
        libraries = $rcl.library_statuses.library
    }
$LibsToAdd | Add-DatabricksLibrary -Verbose


.EXAMPLE
C:\PS> Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region -LibraryType "jar" -LibrarySettings "dbfs:/mnt/libraries/library.jar" -ClusterId "bob-1234"

This example installs a library from a jar which exists in dbfs.

.EXAMPLE 
C:\PS> Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region -LibraryType "pypi" -LibrarySettings 'simplejson2' -ClusterId 'Bob-1234'

The above example applies a pypi library to a cluster by id

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Add-DatabricksLibrary {  
    [cmdletbinding(DefaultParameterSetName = 'Settings')]
    param (
        [Parameter(ParameterSetName = 'InputObject', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Settings', Mandatory = $false)]
        [string]$BearerToken, 
        [Parameter(ParameterSetName = 'InputObject', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Settings', Mandatory = $false)]
        [string]$Region,
        [parameter(ParameterSetName = 'InputObject', ValueFromPipeline, Mandatory = $true)][object]$InputObject,
        [parameter(ParameterSetName = 'Settings', Mandatory = $true)][string]$ClusterId,
        [Parameter(ParameterSetName = 'Settings', Mandatory = $true)][ValidateSet('jar', 'egg', 'maven', 'pypi', 'cran', 'whl')][string]$LibraryType,
        [parameter(ParameterSetName = 'Settings', Mandatory = $true)][string]$LibrarySettings
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters
    

    $uri = "$global:DatabricksURI/api/2.0/libraries/install"

    if ($PSBoundParameters.ContainsKey('InputObject') -eq $false) {

        $Body = @{"cluster_id" = $ClusterId }

        if (($LibrarySettings -notmatch '{') -and ($LibraryType -eq "pypi")) {
            #Pypi and only string passed - try as simple name
            Write-Verbose "Converting to pypi JSON request"
            $LibrarySettings = '{package: "' + $LibrarySettings + '"}'
        }

        if ($LibrarySettings -match '{') {
            # Settings are JSON else assume String (name of library)
            Write-Verbose "Request is in JSON"
            $Libraries = @()
            $Library = @{}
            $Library[$LibraryType] = ($LibrarySettings | ConvertFrom-Json)
            $Libraries += $Library
            $Body['libraries'] = $Libraries
        }
        else {
            Write-Verbose "Request is a string"
            $Libraries = @()
            $Library = @{}
            $Library[$LibraryType] = $LibrarySettings
            $Libraries += $Library
            $Body['libraries'] = $Libraries
        }
    }
    else {
        $Body = $InputObject
    }

    $BodyText = $Body | ConvertTo-Json -Depth 100

    Write-Verbose "Request Body: $BodyText"
    Write-Verbose "Installing library $LibraryType with setting $LibrarySettings to REST API: $uri"
    try {
        Invoke-RestMethod -Uri $uri -Body $BodyText -Method 'POST' -Headers $Headers
    }
    catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }
}
