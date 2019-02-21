Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Get-DatabricksRun" {
    
    BeforeAll{
        $Region = "westeurope"    
        $JobName = "UnitTestJob-PythonJob"
        $SparkVersion = "4.1.x-scala2.11"
        $NodeType = "Standard_D3_v2"
        $MinNumberOfWorkers = 1
        $MaxNumberOfWorkers = 1
        $Timeout = 1000
        $MaxRetries = 1
        $ScheduleCronExpression = "0 15 22 ? * *"
        $Timezone = "UTC"
        $PythonPath = "dbfs:/pythonjobtest/File1.py"
        $PythonParameters = "val1", "val2"
        $ClusterId = "0926-081131-crick762"
        $Libraries = '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'
        $InitScripts = 'dbfs:/pythonjobtestFile2.py'
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

