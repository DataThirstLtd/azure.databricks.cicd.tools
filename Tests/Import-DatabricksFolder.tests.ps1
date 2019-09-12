Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

$DatabricksPath = "/Shared/UnitTestImport"

Describe "Import-DatabricksFolder"{
    It "Simple Import" {
        Import-DatabricksFolder -BearerToken $BearerToken -Region $Region `
            -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $DatabricksPath `
            -Verbose
    }
}
