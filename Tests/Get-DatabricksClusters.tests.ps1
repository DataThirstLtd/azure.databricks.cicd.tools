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


Describe "Get-DatabricksClusters"{
    
    It "Get all clusters"{
        $json = Get-DatabricksClusters
        $Json.Count | Should -BeGreaterThan 1
    }

    It "Search for cluster by id"{
        $json = Get-DatabricksClusters
        $ClusterId = $Json.cluster_id[0]
        $json = Get-DatabricksClusters -ClusterId $ClusterId
        $Json.cluster_id | Should -Be "$ClusterId"
    }

}
