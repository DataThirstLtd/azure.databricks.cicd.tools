Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region


Describe "Get-DatabricksSecretScopes"{
    
    It "Get all scopes"{
        $json = Get-DatabricksSecretScopes -BearerToken $BearerToken -Region $Region
    }

    It "Search for scope by name"{
        $json = Get-DatabricksSecretScopes -BearerToken $BearerToken -Region $Region -ScopeName "Test1"
    }

}
