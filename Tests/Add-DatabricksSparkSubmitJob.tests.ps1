Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Add-DatabricksSparkSubmitJob" {
    $Region = "westeurope"    
    $JobName = "UnitTestJob-SparkSubmit"
    $SparkVersion = "4.1.x-scala2.11"
    $NodeType = "Standard_D3_v2"
    $MinNumberOfWorkers = 1
    $MaxNumberOfWorkers = 4
    $Timeout = 1000
    $MaxRetries = 1
    $ScheduleCronExpression = "0 15 22 ? * *"
    $Timezone = "UTC"
    $SparkSubmitParameters = "--pyFiles", "dbfs:/test.py"

    It "Autoscale with parameters, new cluster" {
        $global:jobId = Add-DatabricksSparkSubmitJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone `
            -SparkSubmitParameters $SparkSubmitParameters `
            -Verbose

        $global:jobId | Should -BeGreaterThan 0
    }

    It "Edit job" {
        $MaxNumberOfWorkers = 1
        $global:jobId = Add-DatabricksSparkSubmitJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone `
            -SparkSubmitParameters $SparkSubmitParameters `
            -Verbose

        $global:jobId | Should -BeGreaterThan 0
    }

    AfterAll{
            Remove-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId $global:jobId
        }
}