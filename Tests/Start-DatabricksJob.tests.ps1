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

$JobName = "StartJobTest"
$SparkVersion = "5.5.x-scala2.11"
$NodeType = "Standard_D3_v2"
$MinNumberOfWorkers = 1
$MaxNumberOfWorkers = 1
$PythonPath = "dbfs:/pythonjobtest/File1.py"
$PythonParameters = "val1", "val2"


Describe "Start-DatabricksJob" { 
    
    It "Start By Job Id" {
        Start-DatabricksJob -JobId $global:jobid -PythonParameters $PythonParameters
    }

    It "Start By Job Name" {
        Start-DatabricksJob -JobName $JobName
    }

    AfterAll{
        Remove-DatabricksJob -JobId $global:jobid
    }

    BeforeAll{
        $global:jobid = Add-DatabricksPythonJob -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -PythonPath $PythonPath -PythonParameters $PythonParameters
    }

}
