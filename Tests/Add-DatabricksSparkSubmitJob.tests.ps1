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





Describe "Add-DatabricksSparkSubmitJob" {
    $Region = "westeurope"
    $JobName = "UnitTestJob-SparkSubmit"
    $SparkVersion = "5.5.x-scala2.11"
    $NodeType = "Standard_D3_v2"
    $MinNumberOfWorkers = 1
    $MaxNumberOfWorkers = 4
    $Timeout = 1000
    $MaxRetries = 1
    $ScheduleCronExpression = "0 15 22 ? * *"
    $Timezone = "UTC"
    $SparkSubmitParameters = "--pyFiles", "dbfs:/test.py"

    It "Autoscale with parameters, new cluster" {
        $global:jobId = Add-DatabricksSparkSubmitJob -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone `
            -SparkSubmitParameters $SparkSubmitParameters 

        $global:jobId | Should -BeGreaterThan 0
    }

    It "Edit job" {
        $MaxNumberOfWorkers = 1
        $global:jobId = Add-DatabricksSparkSubmitJob -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone `
            -SparkSubmitParameters $SparkSubmitParameters 

        $global:jobId | Should -BeGreaterThan 0
    }

    AfterAll{
            Remove-DatabricksJob -JobId $global:jobId
        }
}