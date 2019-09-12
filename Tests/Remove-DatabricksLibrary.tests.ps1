Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region
$egg = "dbfs:/eggs/pipelines-0.0.1-py3.5.egg"
$ClusterId = "0926-081131-crick762"

Describe "Add-DatabricksLibrary" {
    BeforeAll{
        $cluster = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
        $state = ($cluster | Where-Object {$_.cluster_id -eq $ClusterId }).state
        if ($state -eq "TERMINATED"){
            Start-DatabricksCluster -Region $Region -BearerToken $BearerToken -ClusterId $ClusterId
        }
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder "Samples" -FilePattern "*.egg" -TargetLocation "/eggs"
        Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region -LibraryType "egg" -LibrarySettings $egg -ClusterId $ClusterId
    }
    It "Remove Egg"{
        Remove-DatabricksLibrary -BearerToken $BearerToken -Region $Region `
            -LibraryType "egg" -LibrarySettings 'dbfs:/eggs/pipelines-0.0.1-py3.5.egg' `
            -ClusterId $ClusterId

        $Res = Get-DatabricksLibraries -Region $Region -BearerToken $BearerToken -ClusterId $ClusterId 
        ($Res | Where-Object {$_.status -eq "UNINSTALL_ON_RESTART"} | Where-Object {$_.library.egg -eq $egg}).library.egg | Should -Be $egg
    }
}


    