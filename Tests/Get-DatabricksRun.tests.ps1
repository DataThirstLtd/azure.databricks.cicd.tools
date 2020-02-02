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

Describe "Get-DatabricksRun" {
    
    BeforeAll{
        $Region = "westeurope"    
        $Timeout = 1000
        $MaxRetries = 1
        $ScheduleCronExpression = "0 15 22 ? * *"
        $Timezone = "UTC"
        $PythonPath = "dbfs:/pythonjobtest/File1.py"
        $PythonParameters = "val1", "val2"
        $ClusterId = $Config.ClusterId
        $Libraries = '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'
        $Spark_conf = @{"spark.speculation"=$true; "spark.streaming.ui.retainedBatches"= 5}

        $global:RunID = Add-DatabricksPythonJob -JobName "Immediate Job" `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -PythonPath $PythonPath `
            -PythonParameters $PythonParameters -ClusterId $ClusterId `
            -Libraries $Libraries -Spark_conf $Spark_conf -RunImmediate
    }

    It "Get Status" {
        $global:res = Get-DatabricksRun -RunId $global:RunID -StateOnly
    }
}

