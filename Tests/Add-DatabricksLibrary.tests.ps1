Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
Set-Location $PSScriptRoot

$ClusterId = "0926-081131-crick762"

Describe "Add-DatabricksLibrary" {
    BeforeAll{
        $cluster = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
        $state = ($cluster | Where-Object {$_.cluster_id -eq $ClusterId }).state
        if ($state -eq "TERMINATED"){
            Start-DatabricksCluster -Region $Region -BearerToken $BearerToken -ClusterId $ClusterId
        }
    }
    It "Simple add DBFS Jar"{
        Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region `
            -LibraryType "jar" -LibrarySettings 'dbfs:/mnt/libraries/library.jar' `
            -ClusterId $ClusterId

        $Res = Get-DatabricksLibraries -Region $Region -BearerToken $BearerToken -ClusterId $ClusterId
        $Res.library.jar | Where-Object {$_ -eq "dbfs:/mnt/libraries/library.jar"} | Should -Be "dbfs:/mnt/libraries/library.jar"
    }
}


    