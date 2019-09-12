Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

Describe "Get-DatabricksRun" {
    
    BeforeAll{
        $Region = "westeurope"    
        $Timeout = 1000
        $MaxRetries = 1
        $ScheduleCronExpression = "0 15 22 ? * *"
        $Timezone = "UTC"
        $PythonPath = "dbfs:/pythonjobtest/File1.py"
        $PythonParameters = "val1", "val2"
        $ClusterId = "0926-081131-crick762"
        $Libraries = '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'
        $Spark_conf = @{"spark.speculation"=$true; "spark.streaming.ui.retainedBatches"= 5}

        $global:RunID = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName "Immediate Job" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf -RunImmediate
    }

    It "Get Status" {
        $global:res = Get-DatabricksRun -BearerToken $BearerToken -Region $Region -RunId $global:RunID -StateOnly
    }
}

