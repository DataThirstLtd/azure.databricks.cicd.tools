Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

$ExportPath = "/Shared/UnitTest"
$LocalOutputPath = "Output"
New-Item -Name Output -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

Describe "Export-DatabricksFolder"{
    BeforeAll {
        # Upload sample files here with two files in
        Import-DatabricksFolder -BearerToken $BearerToken -Region $Region -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $ExportPath
    }
    It "Folder of files is exported" {
        Export-DatabricksFolder -ExportPath $ExportPath -BearerToken $BearerToken -Region $Region -LocalOutputPath $LocalOutputPath -Verbose
        $Count = (Get-ChildItem -Path $LocalOutputPath).Count
        $Count | Should -Be 3
    }

    AfterAll {
        Remove-Item "$PSScriptRoot\Output" -Force -Recurse
    }
}
