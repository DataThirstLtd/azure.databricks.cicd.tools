Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$DatabricksPath = "/Shared/UnitTestImport"

Set-Location $PSScriptRoot

Describe "Import-DatabricksFolder"{
    It "Simple Import" {
        Import-DatabricksFolder -BearerToken $BearerToken -Region $Region -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $DatabricksPath
    }
}

