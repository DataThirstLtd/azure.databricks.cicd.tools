Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

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
