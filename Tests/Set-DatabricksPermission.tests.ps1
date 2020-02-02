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

Describe "Set-DatabricksPermission" {
    It "Apply cluster permissions" {
        Set-DatabricksPermission -Principal "caroline@datathirst.net" -Permission "CAN_MANAGE" `
            -DatabricksObjectType "cluster" -DatabricksObjectId $Config.ClusterId `
            -Verbose
    }


    It "Apply Secret Scope permissions" {
        Set-DatabricksPermission -Principal "caroline@datathirst.net" -Permission "READ" `
            -DatabricksObjectType "secretScope" -DatabricksObjectId "PermissionsTest" `
            -Verbose
    }

    BeforeAll{
        Set-DatabricksSecret -ScopeName "PermissionsTest" -SecretName "Test" -SecretValue "value"
    }
}



