param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

Describe "Get-DatabricksDBFSFolder" {
    It "Add single file" {
        Add-DatabricksDBFSFile -LocalRootFolder "Samples" -FilePattern "Test.jar"  -TargetLocation '/test' -Verbose
        $Files = Get-DatabricksDBFSFolder -Path /test
        $Found = ($Files | Where-Object {$_.path -eq "/test/Test.jar"})
        $Found.path | Should -Be "/test/Test.jar"
    }

    AfterAll{
        Remove-DatabricksDBFSItem -Path /test
    }

    It "Add folder with subfolder" {
        Add-DatabricksDBFSFile -LocalRootFolder Samples -FilePattern "*.py"  -TargetLocation '/test' -Verbose
        $Files = Get-DatabricksDBFSFolder -Path /test/DummyNotebooks
        $Found = ($Files | Where-Object {$_.Path -like "*.py"}).Count
        $Found | Should -Be 2
    }
}

