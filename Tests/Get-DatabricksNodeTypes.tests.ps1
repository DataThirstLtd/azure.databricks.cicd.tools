Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Get-DatabricksNodeTypes" {
    It "Simple fetch" {
        $json = Get-DatabricksNodeTypes -BearerToken $BearerToken -Region $Region
        $json.Count | Should -BeGreaterThan 5
    }
}

