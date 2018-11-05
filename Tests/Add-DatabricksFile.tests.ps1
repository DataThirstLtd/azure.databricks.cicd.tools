Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Add-DatabricksFile -BearerToken $BearerToken -Region $Region -LocalFile Test.jar  -TargetLocation '/test' -Verbose
