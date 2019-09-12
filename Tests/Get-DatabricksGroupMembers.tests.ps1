Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

$GroupName = "testgroup"

Describe "Get-DatabricksGroupMembers" {
    BeforeAll {
        Add-DatabricksGroup  -BearerToken $BearerToken -Region $Region -GroupName $GroupName 
    }

    It "Simple fetch" {
        $members = Get-DatabricksGroupMembers -BearerToken $BearerToken -Region $Region -GroupName $GroupName 
    }
}
