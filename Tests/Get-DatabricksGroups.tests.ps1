Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in

$Region = "west europe" 

Describe "Get-DatabricksGroups" {
    It "Simple fetch" {
        Get-DatabricksGroups -BearerToken $BearerToken -Region $Region
    }
}

