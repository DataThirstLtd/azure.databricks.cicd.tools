Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

Set-Location $PSScriptRoot

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Describe "Add-DatabricksDBFSFile" {
    It "Add single file" {
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder "Samples" -FilePattern "Test.jar"  -TargetLocation '/test' -Verbose
        $Files = Get-DatabricksDBFSFolder -BearerToken $BearerToken -Region $Region -Path /test
        $Found = ($Files | Where-Object {$_.Path -eq "/test/Test.jar"}).Count
        $Found | Should -Be 1
    }

    AfterAll{
        Remove-DatabricksDBFSItem -BearerToken $BearerToken -Region $Region -Path /test
    }

    It "Add folder with subfolder" {
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder Samples -FilePattern "*.py"  -TargetLocation '/test' -Verbose
        $Files = Get-DatabricksDBFSFolder -BearerToken $BearerToken -Region $Region -Path /test/DummyNotebooks
        $Found = ($Files | Where-Object {$_.Path -like "*.py"}).Count
        $Found | Should -Be 2
    }
}

