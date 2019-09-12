Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Get-DatabricksNodeTypes" {
    It "Simple fetch" {
        $json = Get-DatabricksNodeTypes -BearerToken $BearerToken -Region $Region
        $json.Count | Should -BeGreaterThan 5
    }
}

