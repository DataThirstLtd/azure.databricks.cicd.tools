Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

$ClusterId = $Config.ClusterId

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


    