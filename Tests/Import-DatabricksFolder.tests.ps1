Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

$DatabricksPath = "/Shared/UnitTestImport"

Describe "Import-DatabricksFolder"{
    It "Simple Import" {
        Import-DatabricksFolder -BearerToken $BearerToken -Region $Region `
            -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $DatabricksPath `
            -Verbose
    }
}
