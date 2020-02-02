Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psm1" -Force

Describe "GetKeyValues"{
    $test = @{key1="val1";key2=2;key3=$true}

    It "Simple Execution" {
        GetKeyValues($test) | ConvertTo-Json
    }
}

