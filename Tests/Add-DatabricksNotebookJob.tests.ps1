Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in

Describe "Add-DatabricksNotebookJob" {
    $Region = "westeurope"    
    $JobName = "UnitTestJob"
    $SparkVersion = "4.1.x-scala2.11"
    $NodeType = "Standard_D3_v2"
    $MinNumberOfWorkers = 1
    $MaxNumberOfWorkers = 1
    $Timeout = 1000
    $MaxRetries = 1
    $ScheduleCronExpression = "0 15 22 ? * *"
    $Timezone = "Europe/Warsaw"
    $NotebookPath = "/Shared/Test"
    $NotebookParametersJson = '{"key": "value", "name": "test2"}'
    $ClusterId = "0926-081131-crick762"
    $Libraries = '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'

    It "Autoscale with parameters, new cluster" {
        $JobId = Add-DatabricksNotebookJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -NotebookPath $NotebookPath `
            -NotebookParametersJson $NotebookParametersJson `
            -Libraries $Libraries

        Write-Host $JobId
        $JobId | Should -BeGreaterThan 0
    }

    It "Update Job to use existing cluster" {
        $JobId = Add-DatabricksNotebookJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -NotebookPath $NotebookPath `
            -NotebookParametersJson $NotebookParametersJson -ClusterId $ClusterId `
            -Libraries $Libraries

        $JobId | Should -BeGreaterThan 0
    }
}


