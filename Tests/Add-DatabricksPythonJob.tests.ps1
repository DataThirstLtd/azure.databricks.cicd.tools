param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode) {
    ("Bearer") {
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal") {
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}


Describe "Add-DatabricksPythonJob" {
    $JobName = "UnitTestJob-PythonJob"
    $SparkVersion = "5.5.x-scala2.11"
    $NodeType = "Standard_D3_v2"
    $MinNumberOfWorkers = 1
    $MaxNumberOfWorkers = 1
    $Timeout = 1000
    $MaxRetries = 1
    $ScheduleCronExpression = "0 15 22 ? * *"
    $Timezone = "UTC"
    $PythonPath = "dbfs:/pythonjobtest/File1.py"
    $PythonParameters = "val1", "val2"
    $ClusterId = $Config.ClusterId
    $Libraries = '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'
    $InitScripts = 'dbfs:/pythonjobtestFile2.py'
    $Spark_conf = @{"spark.speculation" = $true; "spark.streaming.ui.retainedBatches" = 5 }
    $MaxConcurrentRuns = 2



    BeforeAll {
        Add-DatabricksDBFSFile -LocalRootFolder Samples/DummyNotebooks -FilePattern 'File*.py' -TargetLocation '/pythonjobtest'
    }

    It "Autoscale with parameters, new cluster" {
        $global:jobid = Add-DatabricksPythonJob -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -MaxConcurrentRuns $MaxConcurrentRuns `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters `
            -Libraries $Libraries -PythonVersion 3 -InitScripts $InitScripts

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Update Job to use existing cluster" {
        $global:jobid = Add-DatabricksPythonJob -JobName $JobName `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -MaxConcurrentRuns $MaxConcurrentRuns `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Job Single Library pypi package" {
        $Libraries = '{"pypi":{package:"simplejson"}}'

        $global:jobid = Add-DatabricksPythonJob -JobName "Libary Test1" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -MaxConcurrentRuns $MaxConcurrentRuns `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Job Single Library jar" {
        $Libraries = '{"jar": "DBFS:/mylibraries/test.jar"}'

        $global:jobid = Add-DatabricksPythonJob -JobName "Libary Test2" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -MaxConcurrentRuns $MaxConcurrentRuns `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    It "Job Single Library egg dbfs" {
        $Libraries = '{"egg": "DBFS:/mylibraries/test.egg"}'

        $global:jobid = Add-DatabricksPythonJob -JobName "Libary Test2" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -MaxConcurrentRuns $MaxConcurrentRuns `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:jobid | Should -BeGreaterThan 0
    }

    
    AfterEach {
        Remove-DatabricksJob -JobId $global:jobid
    }
    AfterAll {
        Remove-DatabricksDBFSItem -Path '/pythonjobtest'
    }
}



Describe "Add-DatabricksPythonJob2" {
    $JobName = "UnitTestJob-PythonJob"
    $SparkVersion = "5.5.x-scala2.11"
    $NodeType = "Standard_D3_v2"
    $MinNumberOfWorkers = 1
    $MaxNumberOfWorkers = 1
    $Timeout = 1000
    $MaxRetries = 1
    $ScheduleCronExpression = "0 15 22 ? * *"
    $Timezone = "UTC"
    $PythonPath = "dbfs:/pythonjobtest/File1.py"
    $PythonParameters = "val1", "val2"
    $ClusterId = $Config.ClusterId
    $Libraries = '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'
    $InitScripts = 'dbfs:/pythonjobtestFile2.py'
    $Spark_conf = @{"spark.speculation" = $true; "spark.streaming.ui.retainedBatches" = 5 }
    $MaxConcurrentRuns = 2

    BeforeAll {
        Add-DatabricksDBFSFile -LocalRootFolder Samples/DummyNotebooks -FilePattern 'File*.py' -TargetLocation '/pythonjobtest'
    }

    It "Execute Immediate Run" {
        $global:res = Add-DatabricksPythonJob -JobName "Immediate Job" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -MaxConcurrentRuns $MaxConcurrentRuns `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf -RunImmediate

        $global:res | Should -BeGreaterThan 0
    }

    AfterAll {
        Remove-DatabricksDBFSItem -Path '/pythonjobtest'
    }

}
