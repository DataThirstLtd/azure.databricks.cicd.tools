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


Describe "Get-DatabricksInstancePool"{
    
    It "Get all clusters"{
        $json = Get-DatabricksInstancePool
    }

    It "Search by name"{
        $json = Get-DatabricksInstancePool -InstancePoolName "test1"
    }

    It "Search by Id"{
        $json = Get-DatabricksInstancePool -InstancePoolId $Config.InstancePoolId
    }

}
