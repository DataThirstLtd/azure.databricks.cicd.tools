Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

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
