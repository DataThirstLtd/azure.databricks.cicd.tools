Set-Location $PSScriptRoot
Import-Module "..\" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Get-DatabricksSparkVersions" {
    It "Simple fetch" {
        $json = Get-DatabricksSparkVersions -BearerToken $BearerToken -Region $Region
        $json.Count | Should -BeGreaterThan 3
    }
}

