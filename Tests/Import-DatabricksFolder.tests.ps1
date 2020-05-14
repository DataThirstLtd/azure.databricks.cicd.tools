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
$CleanTestFolder = 'Samples\DummyNotebooks\CleanTest'
New-Item -Path $UploadFolder -Name "empty" -Force -ItemType Directory | Out-Null

$DatabricksPath = "/Shared/UnitTestImport"
$DatabricksPathClean = "/Shared/UnitTestImportClean2"
$DatabricksPathDoesNotAlreadyExist = "/Shared/NewPath"

Describe "Import-DatabricksFolder Empty Folder"{

    It "Empty Folder" {
        Import-DatabricksFolder `
            -LocalPath "$UploadFolder\empty"  -DatabricksPath $DatabricksPath `
            -Verbose
    }
}

Describe "Import-DatabricksFolder"{

    It "Simple Import" {
        Import-DatabricksFolder -LocalPath $UploadFolder  -DatabricksPath $DatabricksPath
    }

    It "With Clean where files already exist" {
        # Setup existing files
        Import-DatabricksFolder -LocalPath "$CleanTestFolder\Folder1" -DatabricksPath $DatabricksPathClean
        $FilesBeforeCleanUpload = Get-DatabricksWorkspaceFolder -Path $DatabricksPathClean
        "$DatabricksPathClean/CleanTestFile1" | Should -BeIn $FilesBeforeCleanUpload.path

        # Deploy new file with clean flag set
        Import-DatabricksFolder -LocalPath "$CleanTestFolder\Folder2" -DatabricksPath $DatabricksPathClean -Clean
        $FilesAfterCleanUpload = Get-DatabricksWorkspaceFolder -Path $DatabricksPathClean
        $FilesAfterCleanUpload.path | Should be "$DatabricksPathClean/CleanTestFile2"
    }

    It "With Clean on folder that does not already exist" {
        Import-DatabricksFolder -LocalPath "$CleanTestFolder\Folder1" -DatabricksPath $DatabricksPathDoesNotAlreadyExist -Clean
        $FilesAfterCleanUploadToNewFolder = Get-DatabricksWorkspaceFolder -Path $DatabricksPathDoesNotAlreadyExist
        $FilesAfterCleanUploadToNewFolder.path | Should be "$DatabricksPathDoesNotAlreadyExist/CleanTestFile1"
    }
}
