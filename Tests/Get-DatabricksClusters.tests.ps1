Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in
$Region = "west europe" 

$json = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
Write-Output $json

$ClusterName = "Test"
Get-DatabricksClusters -Bearer $BearerToken -Region $Region | Where-Object {$_.cluster_name -eq $ClusterName}