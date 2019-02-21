Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$ResID = "/subscriptions/b146ae31-d42f-4c88-889b-318f2cc23f98/resourceGroups/dataThirstDBTools-RG/providers/Microsoft.KeyVault/vaults/dataThirstcicdtoolkv"

Describe "Add-DatabricksSecretScope" {
    BeforeAll{
            Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "Normal"
            Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "KVScope"
    }
    It "Simple addition"{
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "Normal"  -Verbose
    }

    It "All User Access"{
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "NormalWithPermissions" -AllUserAccess  -Verbose
    }

    It "Key Vault addition"{
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "KVScope" -KeyVaultResourceId $ResID  -Verbose
    }
}
