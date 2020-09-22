param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "ServicePrincipal"
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
        {Add-DatabricksLibrary -InputObject $libraries} | Should Not Throw
        $clusterLibrariesStatus = Get-DatabricksLibraries -ClusterId $Config.AddLibraryClusterId
        $clusterLibrariesStatus.Length | Should Be 12
    }
    AfterAll{
        Remove-DatabricksLibrary -InputObject $libraries
        Start-Sleep -Seconds 10
        Restart-DatabricksCluster -ClusterId $Config.AddLibraryClusterId
    }
}

