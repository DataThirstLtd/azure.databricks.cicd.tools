param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$libraryFile = 'Samples\DummyLibraries\dummylibraries.json'
$libraries = (Get-Content -path $libraryFile -Raw) -replace '__cluster_id__', $Config.AddLibraryClusterId | ConvertFrom-Json
$removelibraries = (Get-Content -path $libraryFile -Raw) -replace '__cluster_id__', $Config.AddLibraryInputClusterId | ConvertFrom-Json

switch ($mode) {
    ("Bearer") {
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal") {
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

Describe "Add-DatabricksLibrary" {
    It "Add Libraries by file" {
        $AddClusterLibFile = Get-DatabricksLibraries -ClusterId $Config.AddLibraryClusterId
        $AddClusterLibFile.Length | Should Be 0
        { Add-DatabricksLibrary -InputObject $libraries } | Should Not Throw
        $clusterLibrariesFile = Get-DatabricksLibraries -ClusterId $Config.AddLibraryClusterId
        $clusterLibrariesFile.Length | Should Be 12
    }
    It "Add Libraries by InputObject" {
        $RemoveClusterLib = Get-DatabricksLibraries -ClusterId $Config.AddLibraryInputClusterId
        $RemoveClusterLib.Length | Should Be 0
        $AddClusterLib = Get-DatabricksLibraries -ClusterId $Config.AddLibraryClusterId -ReturnCluster
        for ($i = 0; $i -lt $AddClusterLib.library_statuses.Length; $i ++) {
            $AddClusterLib.library_statuses[$i].psobject.properties.remove('status')
            $AddClusterLib.library_statuses[$i].psobject.properties.remove('is_library_for_all_clusters')
        } 
        $LibsToRemove = [PSCustomObject]@{
            cluster_id     = $Config.AddLibraryInputClusterId
            libraries = $AddClusterLib.library_statuses.library
        }
        {$LibsToRemove | Add-DatabricksLibrary -Verbose} | Should Not Throw
        $clusterLibrariesInput = Get-DatabricksLibraries -ClusterId $Config.AddLibraryInputClusterId
        $clusterLibrariesInput.Length | Should Be 12
    }

    AfterAll {
        Remove-DatabricksLibrary -InputObject $libraries
        Remove-DatabricksLibrary -InputObject $removelibraries
        Start-Sleep -Seconds 30
        Restart-DatabricksCluster -ClusterId $Config.AddLibraryClusterId
        Restart-DatabricksCluster -ClusterId $Config.AddLibraryInputClusterId
    }
}

