Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$GroupName = "acme"

Describe "Add-DatabricksGroup" {
    It "Simple addition"{
        Add-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $GroupName 
    }

    AfterAll{
        Remove-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $GroupName -Verbose
    }
}
