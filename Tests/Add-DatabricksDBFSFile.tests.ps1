Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

Set-Location $PSScriptRoot

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalFile Samples\Test.jar  -TargetLocation '/test' -Verbose
