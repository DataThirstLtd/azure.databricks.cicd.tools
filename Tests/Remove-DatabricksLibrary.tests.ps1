param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}
$egg = "dbfs:/eggs/pipelines-0.0.1-py3.5.egg"
$ClusterId = $Config.ClusterId

Describe "Add-DatabricksLibrary" {
    BeforeAll{
        $cluster = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
        $state = ($cluster | Where-Object {$_.cluster_id -eq $ClusterId }).state
        if ($state -eq "TERMINATED"){
            Start-DatabricksCluster  -ClusterId $ClusterId
        }
        Add-DatabricksDBFSFile -LocalRootFolder "Samples" -FilePattern "*.egg" -TargetLocation "/eggs"
        Add-DatabricksLibrary -LibraryType "egg" -LibrarySettings $egg -ClusterId $ClusterId
    }
    It "Remove Egg"{
        Remove-DatabricksLibrary `
            -LibraryType "egg" -LibrarySettings 'dbfs:/eggs/pipelines-0.0.1-py3.5.egg' `
            -ClusterId $ClusterId

        $Res = Get-DatabricksLibraries  -ClusterId $ClusterId 
        ($Res | Where-Object {$_.status -eq "UNINSTALL_ON_RESTART"} | Where-Object {$_.library.egg -eq $egg}).library.egg | Should -Be $egg
    }
}


    