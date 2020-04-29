param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode) {
    ("Bearer") {
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal") {
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}


Describe "Export-DatabricksJobs" {

    BeforeAll {
        $jobFile1 = 'Samples\DummyJobs\dummyJob.json'
        $global:jobSettings1 = Get-Content $jobFile1
        $global:JobId1 = Add-DatabricksNotebookJob -JobName "DummyJob" `
            -InputObject ($jobSettings1 | ConvertFrom-Json) -Verbose

        $jobFile2 = 'Samples\DummyJobs\dummyJob2.json'
        $global:jobSettings2 = Get-Content $jobFile2
        $global:JobId2 = Add-DatabricksNotebookJob -JobName "DummyJob2" `
            -InputObject ($jobSettings2 | ConvertFrom-Json) -Verbose
        $global:JobIds = @()
        $global:JobIds = $global:JobId1, $global:JobId2

        $LocalOutputPath = 'Samples\DummyJobsDownExported\'
        New-Item $LocalOutputPath -ItemType Directory -Force | out-Null
        $LocalOutputPath = Resolve-Path $LocalOutputPath
    }

    It "Download 2 Jobs, and content matches" {
        Export-DatabricksJobs -bearerToken $bearerToken -Region $config.Region -JobIds $global:JobIds -LocalOutputPath $LocalOutputPath -SettingsOnly -Verbose
        $Count = (Get-ChildItem -Path $LocalOutputPath).Count
        $Count | Should -Be 2
    }

    It "Imported and Exported File Contents Match"{
        $referenceObj2 = Get-Content -Path ("$LocalOutputPath\DummyJob2.json") | ConvertFrom-Json
        $DifferenceObj2 = Get-Content -Path ('Samples\DummyJobs\dummyJob2.json') | ConvertFrom-Json
        $DummyContent2 = Compare-Object -ReferenceObject $referenceObj2 -DifferenceObject $DifferenceObj2 -IncludeEqual
        $DummyContent2 | Should -BeExactly "@{InputObject=; SideIndicator===}"

        $referenceObj1 = Get-Content -Path ("$LocalOutputPath\DummyJob.json") | ConvertFrom-Json
        $DifferenceObj1 = Get-Content -Path ('Samples\DummyJobs\dummyJob.json') | ConvertFrom-Json
        $DummyContent1 = Compare-Object -ReferenceObject $referenceObj1 -DifferenceObject $DifferenceObj1 -IncludeEqual
        $DummyContent1 | Should -BeExactly "@{InputObject=; SideIndicator===}"
    }

    AfterAll {
        Remove-Item $LocalOutputPath -Force -Recurse
        Remove-DatabricksJob -JobId $global:JobId1
        Remove-DatabricksJob -JobId $global:JobId2
    }
}