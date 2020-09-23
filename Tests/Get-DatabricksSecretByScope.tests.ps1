param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode) {
    ("Bearer") {
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal") {
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

$ScopeName = "DataThirstTest123"

Describe "Get-DatabricksSecretByScope" {
    BeforeAll {
        Add-DatabricksSecretScope -ScopeName $ScopeName  -Verbose
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName 'TestSecretName' -SecretValue 'ohdear'
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName 'AnotherTestSecretName' -SecretValue 'ohdear'
    }
    It "Get all DataBricks Secrets under one scope" {
        $databricksSecrets = Get-DatabricksSecretByScope -ScopeName $ScopeName -Verbose
        $databricksSecrets.count | Should Be 2
    }
    It "Get non existent scope should not fail" {
        Get-DatabricksSecretByScope -ScopeName "Doesntexist"  -Verbose
    }
    It "Get Single Secret from Scope" {
        $databricksSecrets = Get-DatabricksSecretByScope -ScopeName $ScopeName -SecretKey 'TestSecretName' -Verbose
        $databricksSecrets.count | Should Be 1
    }

    It "Get Single Secret from Scope should not fail" {
        $databricksSecrets = Get-DatabricksSecretByScope -ScopeName $ScopeName -SecretKey 'doesntexist' -Verbose
        $databricksSecrets.count | Should Be 0
    }
    AfterAll{
        Remove-DatabricksSecretScope -ScopeName $ScopeName -Verbose
    }
}
