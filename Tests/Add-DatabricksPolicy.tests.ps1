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


Describe "Add-DatabricksPolicy" {
    $name = "testPolicy" + (Get-Random)

    It "Add a policy: $name" {
        $policy = @{
            name       = $name
            definition = '{"spark_version":{"type":"fixed","value":"next-major-version-scala2.12","hidden":true}}'
        }
    
        $id = Add-DatabricksPolicy -policy $policy
    }

    It "Add again policy and raise exception: $name" {
        $policy = @{
            name       = $name
            definition = '{"spark_version":{"type":"fixed","value":"next-major-version-scala2.12","hidden":true}}'
        }
    
        try {
            $id = Add-DatabricksPolicy -policy $policy
        }
        catch {
            $errorThrown = $true
        }
        $errorThrown | Should Be $true
    }
}
  
