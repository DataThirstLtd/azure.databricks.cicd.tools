Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$global:Expires = $null
$global:DatabricksOrgId = $null
$global:RefeshToken = $null

Describe "Get-DatabricksSparkVersions" {
    It "Simple fetch" {
        $json = Get-DatabricksSparkVersions -BearerToken $BearerToken -Region $Region
        $json.Count | Should -BeGreaterThan 3
    }
}

