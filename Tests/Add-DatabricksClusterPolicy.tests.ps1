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


Describe "Add-DatabricksClusterPolicy" {

    BeforeAll {
        $name = "testPolicy" + (Get-Random)
        $policy = @{
            name       = $name
            definition = '{"spark_version":{"type":"fixed","value":"next-major-version-scala2.12","hidden":true}}'
        }
    }

    It "Add a policy" {
        $newPolicyId = Add-DatabricksClusterPolicy -policy $policy

        $newPolicyId | should -Not -BeNullOrEmpty

        $policies = Get-DatabricksClusterPolicies 
        $policy = $policies | where-object {$_.policy_id -eq $newPolicyId}
        $policy | should -Not -BeNullOrEmpty
    }

    It "Add again policy and raise exception" {
        try {
            $id = Add-DatabricksClusterPolicy -policy $policy
        }
        catch {
            $errorThrown = $true
        }
        $errorThrown | Should -Be $true
    }
}
  
