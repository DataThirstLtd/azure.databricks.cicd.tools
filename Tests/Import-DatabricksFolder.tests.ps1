Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$LocalPath = "C:\Test"
$DatabricksPath = "/Shared/Test"

Import-DatabricksFolder -BearerToken $BearerToken -Region $Region -LocalPath $LocalPath -DatabricksPath $DatabricksPath #-Verbose

