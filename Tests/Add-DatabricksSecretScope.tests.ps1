param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="Bearer"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        # Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
        Connect-Databricks -Region $Config.Region -ApplicationId $Config.ApplicationId -Secret $Config.Secret `
            -ResourceGroupName $Config.ResourceGroupName `
            -SubscriptionId $Config.SubscriptionId `
            -WorkspaceName $Config.WorkspaceName `
            -TenantId $Config.TenantId
    }
}

$ResID = $Config.KeyVault

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

    It "Key Vault addition"{
        if ($Mode -eq "Bearer"){
            {Add-DatabricksSecretScope -ScopeName "KVScope" -KeyVaultResourceId $ResID  -Verbose} | Should Throw
        }
        else{
            {Add-DatabricksSecretScope -ScopeName "KVScope" -KeyVaultResourceId $ResID  -Verbose} | Should Not Throw
        }
    }
}
