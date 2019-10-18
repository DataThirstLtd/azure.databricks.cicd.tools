Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
Import-Module "..\Private\ConnectFunctions.ps1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region



$ResID = "/subscriptions/b146ae31-d42f-4c88-889b-318f2cc23f98/resourceGroups/dataThirstDBTools-RG/providers/Microsoft.KeyVault/vaults/dataThirstcicdtoolkv"

Describe "Add-DatabricksSecretScope" {
    BeforeAll{
            Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "Normal"
            Remove-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "KVScope"
    }
    
    BeforeEach{
        Set-GlobalsNull
    }

    It "Simple addition"{
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "Normal"  -Verbose
    }

    It "All User Access"{
        Add-DatabricksSecretScope -BearerToken $BearerToken -Region $Region -ScopeName "NormalWithPermissions" -AllUserAccess  -Verbose
    }

    #It "Key Vault addition"{
    #    Connect-Databricks -Region $Config.Region -ApplicationId $Config.ApplicationId -Secret $Config.Secret `
    #        -ResourceGroupName $Config.ResourceGroupName `
    #        -SubscriptionId $Config.SubscriptionId `
    #        -WorkspaceName $Config.WorkspaceName `
    #        -TenantId $Config.TenantId

    #    Add-DatabricksSecretScope -ScopeName "KVScope" -KeyVaultResourceId $ResID  -Verbose
    #}

    AfterAll{
        Set-GlobalsNull
    }
}
