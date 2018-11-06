Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in

$Region = "westeurope"    
$JobName = "Test script job4"
$SparkVersion = "4.1.x-scala2.11"
$NodeType = "Standard_D3_v2"
$MinNumberOfWorkers = 2
$MaxNumberOfWorkers = 10
$Timeout = 1000
$MaxRetries = 1
$ScheduleCronExpression = "0 15 22 ? * *"
$Timezone = "Europe/Warsaw"
$NotebookPath = "/Shared/Test"
$NotebookParametersJson = '{"key": "value", "name": "test2"}'
$ClusterId = "0926-081131-crick762"

Add-DatabricksNotebookJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
    -SparkVersion $SparkVersion -NodeType $NodeType `
    -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
    -Timeout $Timeout -MaxRetries $MaxRetries `
    -ScheduleCronExpression $ScheduleCronExpression `
    -Timezone $Timezone -NotebookPath $NotebookPath `
    -NotebookParametersJson $NotebookParametersJson # -ClusterId $ClusterId

