param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}



$ResID = "/subscriptions/b146ae31-d42f-4c88-889b-318f2cc23f98/resourceGroups/dataThirstDBTools-RG/providers/Microsoft.KeyVault/vaults/dataThirstcicdtoolkv"

Describe "Add-DatabricksSecretScope" {
    BeforeAll{
            Remove-DatabricksSecretScope -ScopeName "Normal"
            Remove-DatabricksSecretScope -ScopeName "KVScope"
    }

    It "Simple addition"{
        Add-DatabricksSecretScope -ScopeName "Normal"  -Verbose
    }

    It "All User Access"{
        Add-DatabricksSecretScope -ScopeName "NormalWithPermissions" -AllUserAccess  -Verbose
    }

    #It "Key Vault addition"{
    #    Connect-Databricks -Region $Config.Region -ApplicationId $Config.ApplicationId -Secret $Config.Secret `
    #        -ResourceGroupName $Config.ResourceGroupName `
    #        -SubscriptionId $Config.SubscriptionId `
    #        -WorkspaceName $Config.WorkspaceName `
    #        -TenantId $Config.TenantId

    #    Add-DatabricksSecretScope -ScopeName "KVScope" -KeyVaultResourceId $ResID  -Verbose
    #}
}
