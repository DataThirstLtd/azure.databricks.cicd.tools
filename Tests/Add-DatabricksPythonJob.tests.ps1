Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Add-DatabricksPythonJob" {
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

    BeforeAll{
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder Samples/DummyNotebooks -FilePattern 'File*.py' -TargetLocation '/pythonjobtest'
    }

    It "Autoscale with parameters, new cluster" {
        $global:jobid = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters `
            -Libraries $Libraries -PythonVersion 3 -InitScripts $InitScripts -Verbose

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Update Job to use existing cluster" {
        $global:jobid = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Job Single Library pypi package" {
        $Libraries = '{"pypi":{package:"simplejson"}}'

        $global:jobid = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName "Libary Test1" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Job Single Library jar" {
        $Libraries = '{"jar": "DBFS:/mylibraries/test.jar"}'

        $global:jobid = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName "Libary Test2" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Job Single Library egg dbfs" {
        $Libraries = '{"egg": "DBFS:/mylibraries/test.egg"}'

        $global:jobid = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName "Libary Test2" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    

    It "Execute Immediate Run" {
        $global:res = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName "Immediate Job" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf -RunImmediate

        $global:res | Should -BeGreaterThan 0
    }

    AfterAll{
        Remove-DatabricksDBFSItem -BearerToken $BearerToken -Region $Region -Path '/pythonjobtest'
        Remove-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId $global:jobid
    }
}
