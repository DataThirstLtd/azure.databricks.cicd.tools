Set-Location $PSScriptRoot
Import-Module "..\Private\ConnectFunctions.ps1" -Force

$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

$TenantId = $Config.TenantId
$ApplicationId = $Config.ApplicationId
$Secret = $Config.Secret
$URI = "https://login.microsoftonline.com/$tenantId/oauth2/token/"


Describe "ConnectFunctions"{
    
    It "Get new databricks token"{
        Set-GlobalsNull
        Get-AADDatabricksToken
        $global:DatabricksAccessToken | Should -Not -Be $null
    }

    It "Get new management token"{
        Set-GlobalsNull
        Get-AADManagementToken
        $global:ManagementAccessToken | Should -Not -Be $null
    }

    It "Databricks Token Should be expired"{
        $global:DatabricksTokenExpires = (Get-Date).AddDays(-1)
        $res = DatabricksTokenState
        $res | Should -Be "Expired"
    }

    It "Databricks Token Null Should be Missing"{
        $global:DatabricksTokenExpires = $Null
        $res = DatabricksTokenState
        $res | Should -Be "Missing"
    }

    It "Databricks Token valid"{
        $global:DatabricksTokenExpires = (Get-Date).AddDays(1)
        $res = DatabricksTokenState
        $res | Should -Be "Valid"
    }

    It "Management Token Should be expired"{
        $global:ManagementTokenExpires = (Get-Date).AddDays(-1)
        $res = ManagementTokenState
        $res | Should -Be "Expired"
    }

    It "Management Token Null Should be Missing"{
        $global:ManagementTokenExpires = $Null
        $res = ManagementTokenState
        $res | Should -Be "Missing"
    }

    It "Management Token valid"{
        $global:ManagementTokenExpires = (Get-Date).AddDays(1)
        $res = ManagementTokenState
        $res | Should -Be "Valid"
    }

    AfterAll{
        Set-GlobalsNull
    }

}
