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


Describe "Get-DatabricksClusterPolicies" {
    BeforeAll {
        $name = "testPolicy" + (Get-Random)
        $policy = @{
            name       = $name
            definition = '{"spark_version":{"type":"fixed","value":"next-major-version-scala2.12","hidden":true}}'
        }
        $newPolicyId = Add-DatabricksClusterPolicy -policy $policy
    }

    AfterAll {
        Remove-DatabricksClusterPolicy -Id $newPolicyId
    }

    It "Get all Policies" {
        $policies = Get-DatabricksClusterPolicies 
        $policies.Count | Should -BeGreaterThan 0
    }

}
