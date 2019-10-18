

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Set-DatabricksPermission" {
    It "Apply cluster permissions" {
        Set-DatabricksPermission -BearerToken $BearerToken -Region $Region -Principal "caroline@datathirst.net" -Permission "CAN_MANAGE" `
            -DatabricksObjectType "cluster" -DatabricksObjectId $Config.ClusterId `
            -Verbose
    }

}



