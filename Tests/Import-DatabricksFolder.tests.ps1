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

$UploadFolder = 'Samples\DummyNotebooks'
New-Item -Path $UploadFolder -Name "empty" -Force -ItemType Directory | Out-Null

$DatabricksPath = "/Shared/UnitTestImport"

Describe "Import-DatabricksFolder Empty Folder"{

    It "Empty Folder" {
        Import-DatabricksFolder `
            -LocalPath "$UploadFolder\empty"  -DatabricksPath $DatabricksPath `
            -Verbose
    }
}

Describe "Import-DatabricksFolder"{

    It "Simple Import" {
        Import-DatabricksFolder `
            -LocalPath $UploadFolder  -DatabricksPath $DatabricksPath `
            -Verbose
    }

    It "With Clean" {
        Import-DatabricksFolder `
            -LocalPath $UploadFolder  -DatabricksPath $DatabricksPath -Clean `
            -Verbose
    }
}
