Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

$ScopeName = "DataThirstTest123"

Describe "Remove-DatabricksSecretScope" {
    BeforeAll{
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName  -Verbose
    }
    It "Simple addition"{
        Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName  -Verbose
    }

    It "Delete non existent should not fail"{
        Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "Doesnt exist"  -Verbose
    }
}
