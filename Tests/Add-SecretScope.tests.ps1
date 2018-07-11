Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$ScopeName = "DataThirst"

Add-SecretScope -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName  -Verbose

