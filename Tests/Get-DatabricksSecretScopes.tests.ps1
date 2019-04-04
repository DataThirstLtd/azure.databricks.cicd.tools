Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"


Describe "Get-DatabricksSecretScopes"{
    
    It "Get all scopes"{
        $json = Get-DatabricksSecretScopes -BearerToken $BearerToken -Region $Region
    }

    It "Search for scope by name"{
        $json = Get-DatabricksSecretScopes -BearerToken $BearerToken -Region $Region -ScopeName "Test1"
    }

}
