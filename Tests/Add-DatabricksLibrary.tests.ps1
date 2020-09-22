param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "Bearer"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$libraryFile = 'Samples\DummyLibraries\dummylibraries.json'
$libraries = (Get-Content -path $libraryFile -Raw) -replace '__cluster_id__', $Config.AddLibraryClusterId | ConvertFrom-Json

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

        $clusterLibrariesStatus = Get-DatabricksLibraries -ClusterId $Config.AddLibraryClusterId
        $clusterLibrariesStatus.Length | Should Be 0
        { Add-DatabricksLibrary -InputObject $libraries } | Should Not Throw
        $clusterLibrariesStatus = Get-DatabricksLibraries -ClusterId $Config.AddLibraryClusterId
        $clusterLibrariesStatus.Length | Should Be 12
    }
    It "Add Libraries by InputObject" {
        $clusterLibrariesStatus = Get-DatabricksLibraries -ClusterId $Config.AddLibraryClusterId -ReturnCluster
        $clusterLibrariesStatus
        for ($i = 0; $i -lt $clusterLibrariesStatus.library_statuses.Length; $i ++) {
            $clusterLibrariesStatus.library_statuses[$i].psobject.properties.remove('status')
            $clusterLibrariesStatus.library_statuses[$i].psobject.properties.remove('is_library_for_all_clusters')
        } 
        {$clusterLibrariesStatus | Add-DatabricksLibrary -Verbose} | Should Not Throw
    }
    AfterAll {
        Remove-DatabricksLibrary -InputObject $libraries
        Start-Sleep -Seconds 10
        Restart-DatabricksCluster -ClusterId $Config.AddLibraryClusterId
    }
}

