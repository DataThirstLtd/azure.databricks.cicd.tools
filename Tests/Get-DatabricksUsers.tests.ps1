param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "Bearer"
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


Describe "Get-DatabricksUsers" {

    BeforeAll {
        $userName = "myUser" + (Get-Random) + "@foo.com" 
        Add-DatabricksUser -BearerToken $BearerToken -Region $Region -Username $userName
    }

    It "Get all users" {
        $users = Get-DatabricksUsers 
        $users.Resources.Count | Should -BeGreaterOrEqual 0
    }

    It "Get user by id" {

        $users = Get-DatabricksUsers 
        $user = $users.Resources | where-object {$_.userName -eq $userName }

        $searchResult = Get-DatabricksUsers -id $user.id
        $searchResult.id | Should -Be $user.id
    }

}
