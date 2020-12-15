Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
Import-Module "..\Private\ConnectFunctions.ps1" -Force

$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

Describe "ConnectFunctions"{
    BeforeEach{
        Set-GlobalsNull
    }

    It "Legacy token connect"{
        {Connect-Databricks -BearerToken $Config.BearerToken `
        -Region $Config.Region} | Should Not Throw
        $global:DatabricksAccessToken | Should -Not -Be $null
        $global:ManagementAccessToken | Should -Be $null
        $global:Headers | Should -Not -Be $null
    }

    It "Legacy token connect testing connection"{
        {Connect-Databricks -BearerToken $Config.BearerToken `
        -Region $Config.Region -TestConnectDatabricks} | Should Not Throw
        $global:DatabricksAccessToken | Should -Not -Be $null
        $global:ManagementAccessToken | Should -Be $null
        $global:Headers | Should -Not -Be $null
    }


    It "Legacy token connect testing connection with non-existent region"{
        {Connect-Databricks -BearerToken $Config.BearerToken `
        -Region "mars" -TestConnectDatabricks} | Should Throw
        $global:DatabricksAccessToken | Should -Not -Be $null
        $global:ManagementAccessToken | Should -Be $null
        $global:Headers | Should -Not -Be $null
    }


    It "ApplicationId AAD Autentication using OrgId"{
        Connect-Databricks -Region $Config.Region -ApplicationId $Config.ApplicationId -Secret $Config.Secret `
            -DatabricksOrgId $Config.DatabricksOrgId `
            -TenantId $Config.TenantId
        $global:DatabricksAccessToken | Should -Not -Be $null
        $global:ManagementAccessToken | Should -Be $null
        $global:Headers | Should -Not -Be $null
    }

    It "ApplicationId AAD Autentication using ResourceId"{
        Connect-Databricks -Region $Config.Region -ApplicationId $Config.ApplicationId -Secret $Config.Secret `
            -ResourceGroupName $Config.ResourceGroupName `
            -SubscriptionId $Config.SubscriptionId `
            -WorkspaceName $Config.WorkspaceName `
            -TenantId $Config.TenantId
            $global:DatabricksAccessToken | Should -Not -Be $null
            $global:ManagementAccessToken | Should -Not -Be $null
            $global:Headers | Should -Not -Be $null
    }

    AfterAll{
        Set-GlobalsNull
    }
}