Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

$ScopeName = "DataThirst1"
$SecretName = "Test1"
$SecretValue = "mykey"


Describe "Set-DatabricksSecret" {
    It "Simple test value" {
        Set-DatabricksSecret -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
    }
}
