Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in

$Region = "westeurope"    
$JobName = "Test script job"
$SparkVersion = "4.3.1-scala2.11"
$NodeType = "Standard_D3_v2"
$NumberOfWorkers = 3
$Timeout = 1000
$MaxRetries = 1
$ScheduleCronExpression = "0 15 22 ? * *"
$Timezone = "Europe/Warsaw"
$NotebookPath = "/Shared/test.py"
$NotebookParametersJson = '{"key": "value", "name": "test"}'

Add-DatabricksNotebookJob -BearerToken $BearerToken -Region $Region -JobName $JobName -SparkVersion $SparkVersion -NodeType $NodeType -NumberOfWorkers $NumberOfWorkers -Timeout $Timeout -MaxRetries $MaxRetries -ScheduleCronExpression $ScheduleCronExpression -Timezone $Timezone -NotebookPath $NotebookPath -NotebookParametersJson $NotebookParametersJson

