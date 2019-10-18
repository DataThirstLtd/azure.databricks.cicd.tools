Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region
$GroupName = "acme"

Describe "Add-DatabricksGroup" {
    It "Simple addition"{
        Add-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $GroupName 
    }

    AfterAll{
        Remove-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $GroupName -Verbose
    }
}
