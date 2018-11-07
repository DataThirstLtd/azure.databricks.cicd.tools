Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$ScopeName = "DataThirst"

Describe "Add-DatabricksSecretScope" {
    It "Simple addition"{
        $Res = Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName  -Verbose
    }
}
