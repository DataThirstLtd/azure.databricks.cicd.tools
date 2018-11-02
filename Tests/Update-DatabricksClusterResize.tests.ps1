Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope" 
$ClusterId="1102-142510-miff7"

$json = Update-DatabricksClusterResize -BearerToken $BearerToken -Region $Region -ClusterId $ClusterId -MinNumberOfWorkers 1 -MaxNumberOfWorkers 5

Write-Output $json