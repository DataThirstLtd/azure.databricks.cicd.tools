Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Get-DatabricksPermissionLevels" {
    It "Simple fetch" {
        Get-DatabricksPermissionLevels -BearerToken $BearerToken -Region $Region  `
            -DatabricksObjectType "cluster" -DatabricksObjectId $Config.ClusterId `
            -Verbose
    }
}

