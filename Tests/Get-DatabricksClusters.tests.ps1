Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Get-DatabricksClusters"{
    
    It "Get all clusters"{
        $json = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
        $Json.clusters.Count | Should -BeGreaterThan 1
    }

    It "Search for cluster by id"{
        $json = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
        $ClusterId = $Json.cluster_id[0]
        $ClusterName = $Json.cluster_name[0]
        Write-host $ClusterId 
        $json = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region -ClusterId $ClusterId
        $Json.cluster_id | Should -Be "$ClusterId"
    }

}
