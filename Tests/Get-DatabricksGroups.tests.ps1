Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region


Describe "Get-DatabricksGroups" {
    It "Simple fetch" {
        Get-DatabricksGroups -BearerToken $BearerToken -Region $Region
    }
}

