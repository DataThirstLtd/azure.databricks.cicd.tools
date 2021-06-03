param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "Bearer"
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


Describe "Get-DatabricksIPAccessListStatus" {

    AfterAll {
        Set-DatabricksIPAccessList -enabled $false
    }

    It "Get Current Status, set false" {
        Set-DatabricksIPAccessList -enabled $false

        $status = Get-DatabricksIPAccessListStatus
        $status | Should -BeFalse
    }

    It "Switch status" {
        Set-DatabricksIPAccessList -enabled $false  
        Set-DatabricksIPAccessList -enabled $true
        $status = Get-DatabricksIPAccessListStatus
        $status | Should -BeTrue
    }
}
  
