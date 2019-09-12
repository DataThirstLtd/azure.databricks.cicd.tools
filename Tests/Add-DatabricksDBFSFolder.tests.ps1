Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Add-DatabricksDBFSFolder" {
    It "Add-DatabricksDBFSFolder" {
        Add-DatabricksDBFSFolder -Region $Region -BearerToken $BearerToken -FolderPath "/test1/test2/test3"
    }
}

