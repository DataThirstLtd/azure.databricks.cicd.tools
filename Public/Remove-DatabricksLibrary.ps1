<#
.SYNOPSIS
Remove a library from a cluster - note the cluster must be restarted to complete the uninstall (this command will NOT restart the cluster for you)

.DESCRIPTION
Remove a library from a cluster - note the cluster must be restarted to complete the uninstall (this command will NOT restart the cluster for you)

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ClusterId
ClusterId for existing Databricks cluster. Does not need to be running. See Get-DatabricksClusters.

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

.PARAMETER InputObject
Can take an object that is correctly formatted so that more than one library can be removed.

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
    $LibsToRemove = [PSCustomObject]@{
        cluster_id     = $clusterId
        libraries = $rcl.library_statuses.library
    }
$LibsToRemove | Remove-DatabricksLibrary -Verbose

.EXAMPLE
PS C:\> Remove-DatabricksLibrary -BearerToken $BearerToken -Region $Region -ClusterId 'Bob-1234'

.NOTES
Author: Simon D'Morias / Data Thirst Ltd 

#>  

Function Remove-DatabricksLibrary { 
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

    $uri = "api/2.0/libraries/uninstall"

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

    $BodyText = $Body | ConvertTo-Json -Depth 10

    Write-Verbose "Request Body: $BodyText"
    Write-Verbose "Uninstalling library $LibraryType with setting $LibrarySettings to REST API: $uri"
    try {
        Invoke-RestMethod -Uri "$global:DatabricksURI/$uri" -Body $BodyText -Method 'POST' -Headers $Headers
    }
    catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }
}
