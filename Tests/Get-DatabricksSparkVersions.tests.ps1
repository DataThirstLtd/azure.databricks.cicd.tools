Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Get-DatabricksSparkVersions" {
    It "Simple fetch" {
        $json = Get-DatabricksSparkVersions -BearerToken $BearerToken -Region $Region
        $json.Count | Should -BeGreaterThan 3
    }
}

