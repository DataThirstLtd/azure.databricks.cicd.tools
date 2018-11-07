Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$ExportPath = "/Shared/UnitTest"
$LocalOutputPath = "Output"

Set-Location $PSScriptRoot

Describe "Export-DatabricksFolder"{
    BeforeAll {
        # Upload sample files here with two files in
        Import-DatabricksFolder -BearerToken $BearerToken -Region $Region -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $ExportPath
    }
    It "Folder of files is exported" {
        Export-DatabricksFolder -ExportPath $ExportPath -BearerToken $BearerToken -Region $Region -LocalOutputPath $LocalOutputPath -Verbose
        $Count = (Get-ChildItem -Path $LocalOutputPath).Count
        $Count | Should -Be 2
    }
}
