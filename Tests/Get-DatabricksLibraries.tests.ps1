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

#TODO - Create dummy cluster
$ClusterId = $Config.ClusterId

Describe "Get-DatabricksLibraries" {
    It "Simple fetch" {
        $json = Get-DatabricksLibraries -ClusterId $ClusterId
        $json.Count | Should -BeGreaterOrEqual 0
    }
}

