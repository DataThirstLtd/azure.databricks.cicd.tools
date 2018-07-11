Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$ScopeName = "DataThirst1"
$SecretName = "Test1"
$SecretValue = "mykey"

Set-Secret -BearerToken $BearerToken -Region $Region -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose