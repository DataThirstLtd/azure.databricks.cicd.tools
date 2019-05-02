Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Get-DatabricksJobRunList" {
    It "Get Status" {
        Get-DatabricksJobRunList -BearerToken $BearerToken -Region $Region -JobId 280 -Limit 2
    }
}

