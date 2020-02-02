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

$global:Expires = $null
$global:DatabricksOrgId = $null
$global:RefeshToken = $null
$global:jobs 

Describe "Get-DatabricksJobs" {
    BeforeAll{
        $JobName = "Test script job4"
        $SparkVersion = "5.5.x-scala2.11"
        $NodeType = "Standard_D3_v2"
        $MinNumberOfWorkers = 2
        $MaxNumberOfWorkers = 10
        $Timeout = 1000
        $MaxRetries = 1
        $ScheduleCronExpression = "0 15 22 ? * *"
        $Timezone = "Europe/Warsaw"
        $NotebookPath = "/Shared/Test"
        $NotebookParametersJson = '{"key": "value", "name": "test2"}'

        $global:JobId = Add-DatabricksNotebookJob -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Timeout $Timeout -MaxRetries $MaxRetries `
            -ScheduleCronExpression $ScheduleCronExpression `
            -Timezone $Timezone -NotebookPath $NotebookPath `
            -NotebookParametersJson $NotebookParametersJson 
    }
    It "Simple Fetch" {
        $jobs = Get-DatabricksJobs -BearerToken $BearerToken -Region $Region
        $jobs.job_id[0] | Should -BeGreaterThan 0
    }

    AfterAll{
        Remove-DatabricksJob  -JobId $global:JobId
    }
}

