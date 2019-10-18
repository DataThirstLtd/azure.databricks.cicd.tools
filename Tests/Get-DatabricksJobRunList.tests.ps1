Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Get-DatabricksJobRunList" {
    BeforeAll{
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
        $ClusterId = $Config.ClusterId
        $Libraries = '{"jar": "DBFS:/mylibraries/test.jar"}'
        $Spark_conf = @{"spark.speculation"=$true; "spark.streaming.ui.retainedBatches"= 5}
        $JarMainClass = 'com.test'

        $global:jobid = Add-DatabricksJarJob -BearerToken $BearerToken -Region $Region -JobName "DummyJob-For-Get-DatabricksJobRunList" `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -JarPath $JarPath `
            -JarParameters $JarParameters `
            -Libraries $Libraries -JarMainClass $JarMainClass -Verbose
    }
    It "Get Status" {
        Get-DatabricksJobRunList -BearerToken $BearerToken -Region $Region -JobId $global:jobid -Limit 2
    }
}

