Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in
$Region = "west europe" 

$ClusterId = "0926-081131-crick762"

$json = Get-DatabricksLibraries -BearerToken $BearerToken -Region $Region -ClusterId $ClusterId
Write-Output $json
