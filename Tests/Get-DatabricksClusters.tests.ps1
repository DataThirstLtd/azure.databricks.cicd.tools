Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region


Describe "Get-DatabricksClusters"{
    
    It "Get all clusters"{
        $json = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
        $Json.Count | Should -BeGreaterThan 1
    }

    It "Search for cluster by id"{
        $json = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
        $ClusterId = $Json.cluster_id[0]
        $json = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region -ClusterId $ClusterId
        $Json.cluster_id | Should -Be "$ClusterId"
    }

}
