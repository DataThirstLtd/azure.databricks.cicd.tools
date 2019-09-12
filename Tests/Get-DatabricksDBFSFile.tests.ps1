Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region


Describe "Get-DatabricksDBFSFile"{
    
    BeforeAll{
        Add-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -LocalRootFolder "Samples" -FilePattern "Test.jar"  -TargetLocation '/test' -Verbose
    }
    It "Get file"{
        Get-DatabricksDBFSFile -BearerToken $BearerToken -Region $Region -DBFSFile '/test/Test.jar' -TargetFile './Samples/Test2.jar' -Verbose
    }

   

}
