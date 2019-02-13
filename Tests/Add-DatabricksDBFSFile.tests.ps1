Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
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

    #It "Large file and small" {
    #    Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder "/Users/simon/Repos/" -FilePattern "*.txt"  -TargetLocation '/test3/' -Verbose
    #    $Files = Get-DatabricksDBFSFolder -BearerToken $BearerToken -Region $Region -Path /test3
    #    $Found = ($Files | Where-Object {$_.Path -like "*.txt"}).Count
    #    $Found | Should -Be 4
    #}

    It "Add folder with subfolder" {
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder Samples/DummyNotebooks -FilePattern "*.py"  -TargetLocation '/test2/' -Verbose
        $Files = Get-DatabricksDBFSFolder -BearerToken $BearerToken -Region $Region -Path /test2
        $Found = ($Files | Where-Object {$_.Path -like "*.py"}).Count
        $Found | Should -Be 2
    }
}

Pop-Location


