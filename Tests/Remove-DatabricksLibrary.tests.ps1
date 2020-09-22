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

Describe "Remove-DatabricksLibrary" {
    It "Remove Library by file" {
        $libraryFile = 'Samples\DummyLibraries\dummylibraries.json'
        $libraries = (Get-Content -path $libraryFile -Raw) -replace '__cluster_id__', $Config.RemoveLibraryClusterId | ConvertFrom-Json
        Add-DatabricksLibrary -InputObject $libraries
        Start-Sleep -Seconds 20
        {Remove-DatabricksLibrary -InputObject $libraries} | Should Not Throw
        Start-Sleep -Seconds 20
        $clusterLibrariesStatus = Get-DatabricksLibraries -ClusterId $Config.RemoveLibraryClusterId
        foreach ($cls in $clusterLibrariesStatus) {
            $cls.status | Should Be 'UNINSTALL_ON_RESTART'
        }
        $clusterLibrariesStatus.Length | Should Be 12
    }
    AfterAll{
        Restart-DatabricksCluster -ClusterId $Config.RemoveLibraryClusterId
    }
}
