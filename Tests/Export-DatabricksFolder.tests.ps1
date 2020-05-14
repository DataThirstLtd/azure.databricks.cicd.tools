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

$ExportPath = "/Shared/UnitTest"
$LocalOutputPath = "Output"
New-Item -Name Output -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

Describe "Export-DatabricksFolder"{
    BeforeAll {
        # Upload sample files here with two files in
        Import-DatabricksFolder -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $ExportPath
    }
    It "Folder of files is exported" {
        Export-DatabricksFolder -ExportPath $ExportPath -LocalOutputPath $LocalOutputPath -Verbose
        $Count = (Get-ChildItem -Path $LocalOutputPath).Count
        $Count | Should -BeGreaterThan 0
    }

    AfterAll {
        Remove-Item "$PSScriptRoot\Output" -Force -Recurse
    }
}
