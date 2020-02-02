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

$ClusterId = $Config.ClusterId

Describe "Add-DatabricksLibrary" {
    BeforeAll{
        $cluster = Get-DatabricksClusters
        $state = ($cluster | Where-Object {$_.cluster_id -eq $ClusterId }).state
        if ($state -eq "TERMINATED"){
            Start-DatabricksCluster  -ClusterId $ClusterId
        }
    }
    It "Simple add DBFS Jar"{
        Add-DatabricksLibrary `
            -LibraryType "jar" -LibrarySettings 'dbfs:/mnt/libraries/library.jar' `
            -ClusterId $ClusterId

        $Res = Get-DatabricksLibraries -ClusterId $ClusterId
        $Res.library.jar | Where-Object {$_ -eq "dbfs:/mnt/libraries/library.jar"} | Should -Be "dbfs:/mnt/libraries/library.jar"
    }
}


    