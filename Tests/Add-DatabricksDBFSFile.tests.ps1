Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

Set-Location $PSScriptRoot

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Push-Location

Describe "Add-DatabricksDBFSFile" {
    It "Add single file" {
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder "Samples" -FilePattern "Test.jar"  -TargetLocation '/test' -Verbose
        $Files = Get-DatabricksDBFSFolder -BearerToken $BearerToken -Region $Region -Path /test
        $Found = ($Files | Where-Object {$_.Path -like "*est.jar"}).path
        $Found | Should -BeLike "*test.jar"
    }

    AfterAll{
        Remove-DatabricksDBFSItem -BearerToken $BearerToken -Region $Region -Path /test
        Remove-DatabricksDBFSItem -BearerToken $BearerToken -Region $Region -Path /test2
    }

    BeforeAll{
        Remove-DatabricksDBFSItem -BearerToken $BearerToken -Region $Region -Path /test
        Remove-DatabricksDBFSItem -BearerToken $BearerToken -Region $Region -Path /test2
    }

    It "Add folder with subfolder" {
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder Samples/DummyNotebooks -FilePattern "*.py"  -TargetLocation '/test2/' -Verbose
        $Files = Get-DatabricksDBFSFolder -BearerToken $BearerToken -Region $Region -Path /test2
        $Found = ($Files | Where-Object {$_.Path -like "*.py"}).Count
        $Found | Should -Be 2
    }
}

Pop-Location
