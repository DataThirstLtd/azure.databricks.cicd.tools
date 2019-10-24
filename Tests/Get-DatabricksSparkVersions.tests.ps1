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

Describe "Get-DatabricksSparkVersions" {
    It "Simple fetch" {
        $json = Get-DatabricksSparkVersions
        $json.Count | Should -BeGreaterThan 3
    }
}

