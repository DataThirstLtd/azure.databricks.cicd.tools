param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode) {
    ("Bearer") {
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal") {
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

function WaitCluster{
    param([string]$ClusterId)
    $Start = Get-Date
    $State = ""
    $BadStates = @("TERMINATING","TERMINATED","ERROR", "UNKNOWN", "RESIZING")
    while (($State -ne "RUNNING") -and ($Timer.Minutes -lt 7)){
        $State = (Get-DatabricksClusters -ClusterId $Config.RemoveLibraryClusterId).state
        if ($BadStates.contains($State)){
            Write-Error "Cluster $ClusterId in $State state"
            return $false
        }
        Start-Sleep -Seconds 10
        $Timer = New-TimeSpan -Start $Start -End (Get-Date)
    }
    return $true
}

Describe "Remove-DatabricksLibrary" {
    BeforeAll{
        Start-DatabricksCluster -ClusterId $Config.AddLibraryClusterId -ErrorAction:SilentlyContinue
        Start-DatabricksCluster -ClusterId $Config.AddLibraryInputClusterId -ErrorAction:SilentlyContinue
        Start-DatabricksCluster -ClusterId $Config.RemoveLibraryClusterId -ErrorAction:SilentlyContinue
        if (!((WaitCluster $Config.AddLibraryClusterId) -and (WaitCluster $Config.AddLibraryInputClusterId) -and (WaitCluster $Config.RemoveLibraryClusterId))){
            throw "Clusters not started"
        }
    }
    BeforeEach {
        $libraryFile = 'Samples\DummyLibraries\dummylibraries.json'
        $libraries = (Get-Content -path $libraryFile -Raw) -replace '__cluster_id__', $Config.RemoveLibraryClusterId | ConvertFrom-Json
        Add-DatabricksLibrary -InputObject $libraries
        Start-Sleep -Seconds 30
    }
    It "Remove Libraries by file" {
        { Remove-DatabricksLibrary -InputObject $libraries } | Should Not Throw
    }

    It "Remove Libraries by InputObject" {
        $RemoveClusterLib = Get-DatabricksLibraries -ClusterId $Config.RemoveLibraryClusterId
        $RemoveClusterLib.Length | Should Be 12
        foreach ($cls in $RemoveClusterLib) {
            $cls.status | Should Be 'INSTALLED'
        }
        $rcl = Get-DatabricksLibraries -ClusterId $Config.RemoveLibraryClusterId -ReturnCluster
        for ($i = 0; $i -lt $rcl.library_statuses.Length; $i ++) {
            $rcl.library_statuses[$i].psobject.properties.remove('status')
            $rcl.library_statuses[$i].psobject.properties.remove('is_library_for_all_clusters')
        } 
        $LibsToRemove = [PSCustomObject]@{
            cluster_id     = $Config.RemoveLibraryClusterId
            libraries = $rcl.library_statuses.library
        }
        {$LibsToRemove | Remove-DatabricksLibrary -Verbose} | Should Not Throw
    }
    AfterEach {
        Start-Sleep -Seconds 40
        $clusterLibrariesStatus = Get-DatabricksLibraries -ClusterId $Config.RemoveLibraryClusterId
        foreach ($cls in $clusterLibrariesStatus) {
            $cls.status | Should Be 'UNINSTALL_ON_RESTART'
        }
        $clusterLibrariesStatus.Length | Should Be 12
    }
    AfterAll {
        Restart-DatabricksCluster -ClusterId $Config.RemoveLibraryClusterId
    }
}
