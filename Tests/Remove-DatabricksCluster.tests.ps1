Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope" 
#$ClusterId="1102-134319-ray879"
$ClusterName = "TestCluster4"
$json = Remove-DatabricksCluster -BearerToken $BearerToken -Region $Region -ClusterName $ClusterName # -ClusterId $ClusterId

Write-Output $json