param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

Push-Location

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

Describe "Add-DatabricksDBFSFile" {
    It "Add single file" {
        Add-DatabricksDBFSFile -LocalRootFolder "Samples" -FilePattern "Test.jar"  -TargetLocation '/test' -Verbose
        $Files = Get-DatabricksDBFSFolder -Path /test
        $Found = ($Files | Where-Object {$_.Path -like "*est.jar"}).path
        $Found | Should -BeLike "*test.jar"
    }

    It "Add large single file" {
        Add-DatabricksDBFSFile -LocalRootFolder "Samples" -FilePattern "aw.csv"  -TargetLocation '/test' -Verbose
        $Files = Get-DatabricksDBFSFolder -Path /test
        $Found = ($Files | Where-Object {$_.Path -like "*w.csv"}).path
        $Found | Should -BeLike "*w.csv"
    }

    AfterAll{
        Remove-DatabricksDBFSItem -Path /test
        Remove-DatabricksDBFSItem -Path /test2
    }

    BeforeAll{
        Remove-DatabricksDBFSItem -Path /test
        Remove-DatabricksDBFSItem -Path /test2
    }

    It "Add folder with subfolder" {
        Add-DatabricksDBFSFile -LocalRootFolder Samples/DummyNotebooks -FilePattern "*.py"  -TargetLocation '/test2/' -Verbose
        $Files = Get-DatabricksDBFSFolder -Path /test2
        $Found = ($Files | Where-Object {$_.Path -like "*.py"}).Count
        $Found | Should -Be 3
    }

    It "Logs the filename being written when called with -Verbose"{
        $output = $(Add-DatabricksDBFSFile -LocalRootFolder "Samples" -FilePattern "Test.jar"  -TargetLocation '/test' -Verbose) 4>&1
        
        $output[3] | Should -be "Pushing file $PSScriptRoot/Samples/Test.jar to /test/Test.jar"
    }
}

Pop-Location


