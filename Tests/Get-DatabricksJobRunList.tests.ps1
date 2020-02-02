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

Describe "Get-DatabricksJobRunList" {
    BeforeAll{
        $SparkVersion = "5.5.x-scala2.11"
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

        $global:jobid = Add-DatabricksJarJob -JobName "DummyJob-For-Get-DatabricksJobRunList" `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -JarPath $JarPath `
            -JarParameters $JarParameters `
            -Libraries $Libraries -JarMainClass $JarMainClass -Verbose
    }
    It "Get Status" {
        Get-DatabricksJobRunList -JobId $global:jobid -Limit 2
    }

    AfterAll{
        Remove-DatabricksJob -JobId $global:jobid
    }
}

