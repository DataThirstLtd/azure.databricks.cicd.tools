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
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

$ScopeName = "TestRemove"
$SecretName = "Test"
$SecretValue = "mykey"


Describe "Set-DatabricksSecret" {
    BeforeAll{
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
    }
    It "Simple test value" {
        Remove-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -Verbose
    }
}
