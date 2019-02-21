Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in

$Region = "west europe" 
$GroupName = "testgroup"

Describe "Get-DatabricksGroupMembers" {
    BeforeAll {
        Add-DatabricksGroup  -BearerToken $BearerToken -Region $Region -GroupName $GroupName 
    }

    It "Simple fetch" {
        $members = Get-DatabricksGroupMembers -BearerToken $BearerToken -Region $Region -GroupName $GroupName 
    }
}
