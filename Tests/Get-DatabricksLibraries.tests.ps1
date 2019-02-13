Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

#TODO - Create dummy cluster
$ClusterId = "0926-081131-crick762"

Describe "Get-DatabricksLibraries" {
    It "Simple fetch" {
        $json = Get-DatabricksLibraries -BearerToken $BearerToken -Region $Region -ClusterId $ClusterId
        $json.Count | Should -BeGreaterThan 0
    }
}

