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

Describe "Add-DatabricksNotebookJob" {
    $JobName = "UnitTestJob"
    $SparkVersion = "5.5.x-scala2.11"
    $NodeType = "Standard_D3_v2"
    $MinNumberOfWorkers = 1
    $MaxNumberOfWorkers = 1
    $Timeout = 1000
    $MaxRetries = 1
    $ScheduleCronExpression = "0 15 22 ? * *"
    $Timezone = "Europe/Warsaw"
    $NotebookPath = "/Shared/Test"
    $NotebookParametersJson = '{"key": "value", "name": "test2"}'
    $ClusterId = $Config.ClusterId
    $Libraries = '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'
    $Spark_conf = @{"spark.speculation" = $true; "spark.streaming.ui.retainedBatches" = 5 }

    It "Autoscale with parameters, new cluster" {
        $global:JobId2 = Add-DatabricksNotebookJob -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -NotebookPath $NotebookPath `
            -NotebookParametersJson $NotebookParametersJson `
            -Libraries $Libraries -Spark_conf $Spark_conf

        $global:JobId2 | Should -BeGreaterThan 0
    }

    It "Update Job to use existing cluster" {
        $global:JobId1 = Add-DatabricksNotebookJob -JobName $JobName `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -NotebookPath $NotebookPath `
            -NotebookParametersJson $NotebookParametersJson -ClusterId $ClusterId `
            -Libraries $Libraries

        $global:JobId1 | Should -BeGreaterThan 0
    }

    It "With run now" {
        $global:JobId = Add-DatabricksNotebookJob -JobName $JobName `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -Timezone $Timezone -NotebookPath $NotebookPath `
            -ClusterId $ClusterId `
            -NotebookParametersJson $NotebookParametersJson `
            -RunImmediate -Verbose

        $global:JobId | Should -BeGreaterThan 0
    }

    It "With Settings Saved, Existing Cluster" {
        $jobFile = 'Samples\DummyJobs\dummyJob.json'
        $jobSettings = Get-Content $jobFile
        $global:JobId3 = Add-DatabricksNotebookJob -JobName "DummyJob" `
            -InputObject ($jobSettings | ConvertFrom-Json) -Verbose
    }

    It "With Settings Saved, Create Cluster" {
        $jobFile = 'Samples\DummyJobs\dummyJob2.json'
        $jobSettings = Get-Content $jobFile
        $global:JobId4 = Add-DatabricksNotebookJob -JobName "DummyJob2" `
            -InputObject ($jobSettings | ConvertFrom-Json) -Verbose
    }
    
    $global:JobId3 | Should -BeGreaterThan 0

    AfterAll {
        Remove-DatabricksJob -JobId $global:JobId1
        Remove-DatabricksJob -JobId $global:JobId3
        Remove-DatabricksJob -JobId $global:JobId4
    }
}