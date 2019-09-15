Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

#TODO - Create dummy cluster
$ClusterId = $Config.ClusterId

Describe "Get-DatabricksLibraries" {
    It "Simple fetch" {
        $json = Get-DatabricksLibraries -BearerToken $BearerToken -Region $Region -ClusterId $ClusterId
        $json.Count | Should -BeGreaterThan 0
    }
}

