Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

$DatabricksPath = "/Shared/UnitTestImport"

Describe "Import-DatabricksFolder"{
    BeforeAll {
        Import-DatabricksFolder -BearerToken $BearerToken -Region $Region `
            -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $DatabricksPath `
            -Verbose
    }
    it "Delete single item"{
        Remove-DatabricksNotebook -BearerToken $BearerToken -Region $Region -Path '/Shared/UnitTestImport/SubFolder/File3'
    }

    it "Delete Folder with Recurse"{
        Remove-DatabricksNotebook -BearerToken $BearerToken -Region $Region -Path $DatabricksPath -Recursive
    }
}
