Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force
$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt" # Create this file in the Tests folder with just your bearer token in
$Region = "west europe" 

Describe "Get-DatabricksNodeTypes" {
    It "Simple fetch" {
        $json = Get-DatabricksNodeTypes -BearerToken $BearerToken -Region $Region
        $json.Count | Should -BeGreaterThan 5
    }
}

