Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$ExportPath = "/Shared/Test"
$LocalOutputPath = "Output"

Export-DatabricksFolder -ExportPath $ExportPath -BearerToken $BearerToken -Region $Region -LocalOutputPath $LocalOutputPath -Verbose