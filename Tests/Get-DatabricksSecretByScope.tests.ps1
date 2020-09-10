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
    It "Get DataBricks Secrets - should be two results" {
        $databricksSecrets = Get-DatabricksSecretByScope -ScopeName $ScopeName -Verbose
        $databricksSecrets.count | Should Be 2
    }
    It "Delete non existent should not fail" {
        Get-DatabricksSecretByScope -ScopeName "Doesntexist"  -Verbose
    }
    AfterAll{
        Remove-DatabricksSecretScope -ScopeName $ScopeName -Verbose
    }
}
