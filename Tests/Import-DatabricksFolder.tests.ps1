param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

$DatabricksPath = "/Shared/UnitTestImport"

Describe "Import-DatabricksFolder"{
    It "Simple Import" {
        Import-DatabricksFolder `
            -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $DatabricksPath `
            -Verbose
    }

    It "With Clean" {
        Import-DatabricksFolder `
            -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $DatabricksPath -Clean `
            -Verbose
    }
}
