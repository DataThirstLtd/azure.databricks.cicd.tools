Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

$ScopeName = "DataThirst1"
$SecretName = "Test1"
$SecretValue = "mykey"


Describe "Set-DatabricksSecret" {
    It "Simple test value" {
        Set-DatabricksSecret -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
    }
}
