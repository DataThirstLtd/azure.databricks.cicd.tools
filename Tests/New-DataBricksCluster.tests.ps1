Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope" 
$ClusterName="TestCluster4"
$SparkVersion="4.0.x-scala2.11"
$NodeType="Standard_D3_v2"
$MinNumberOfWorkers=2
$MaxNumberOfWorkers=3
$Spark_conf = '{"spark.speculation": true, "spark.streaming.ui.retainedBatches": 5}'
$CustomTags = '{"key": "CreatedBy", "value": "simon"}', '{"key":"Date","value":"1st Jan 2000"}'
# $InitScripts = '{"key": "Script1", "value": "dbfs:/script/script1"}', '{"key":"Script2","value":"dbfs:/script/script2"}'
$SparkEnvVars = '{"key": "SPARK_WORKER_MEMORY", "value": "28000m"}', '{"key":"SPARK_LOCAL_DIRS","value":"/local_disk0"}'
$AutoTerminationMinutes = 90

$json = New-DatabricksCluster -BearerToken $BearerToken -Region $Region -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
     -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
     -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes -SparkEnvVars $SparkEnvVars # -UniqueNames -Update

Write-Output $json