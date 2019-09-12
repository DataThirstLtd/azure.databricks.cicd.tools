Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Add-DatabricksJarJob" {
  
    $JobName = "UnitTestJob-JarJob"
    $SparkVersion = "5.3.x-scala2.11"
    $NodeType = "Standard_D3_v2"
    $MinNumberOfWorkers = 1
    $MaxNumberOfWorkers = 1
    $Timeout = 1000
    $MaxRetries = 1
    $ScheduleCronExpression = "0 15 22 ? * *"
    $Timezone = "UTC"
    $JarPath = "test/test1.jar"
    $JarParameters = "val1", "val2"
    $ClusterId = "0926-081131-crick762"
    $Libraries = '{"jar": "DBFS:/mylibraries/test.jar"}'
    $Spark_conf = @{"spark.speculation"=$true; "spark.streaming.ui.retainedBatches"= 5}
    $JarMainClass = 'com.test'

    It "Autoscale with parameters, new cluster" {
        $global:jobid = Add-DatabricksJarJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -JarPath $JarPath `
            -JarParameters $JarParameters `
            -Libraries $Libraries -JarMainClass $JarMainClass -Verbose

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Update Job to use existing cluster" {
        $global:jobid = Add-DatabricksJarJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -JarPath $JarPath `
            -JarParameters $JarParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf `
            -JarMainClass $JarMainClass

        $global:jobid | Should -BeGreaterThan 0
    }

    AfterAll{
        Remove-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId $global:jobid
    }
}