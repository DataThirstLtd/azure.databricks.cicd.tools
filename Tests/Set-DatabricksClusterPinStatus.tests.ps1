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


Describe "Set-DatabricksClusterPinStatus" {

    BeforeAll {
        $clusters = Get-DatabricksClusters 
        $cluster = $clusters[0]
    }

    AfterAll {
      
    }

    It "Pin a cluster" {
        Set-DatabricksClusterPinStatus -clusterId $cluster.cluster_id -enablePin $true

        $listStatus = Get-DatabricksClusterPinStatus
        $status = Get-DatabricksClusterPinStatus | where-object {$_.cluster_id -eq $cluster.cluster_id}

        $status.pinned_by_user_name | should -not -be $null
    }

    It "Unpin a cluster" {
        Set-DatabricksClusterPinStatus -clusterId $cluster.cluster_id -enablePin $true
        Set-DatabricksClusterPinStatus -clusterId $cluster.cluster_id -enablePin $false

        $listStatus = Get-DatabricksClusterPinStatus
        $status = Get-DatabricksClusterPinStatus | where-object {$_.cluster_id -eq $cluster.cluster_id}

        $status.pinned_by_user_name | should -be $null
    }
}
  