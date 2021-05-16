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
        $newUser = Add-DatabricksUser -BearerToken $BearerToken -Region $Region -Username $userName
    }

    AfterAll {
        Remove-DatabricksUser -UserId $newUser.Id
    }

    It "Get all users" {
        $users = Get-DatabricksUsers 
        $users.Resources.Count | Should -BeGreaterThan 0
    }

    It "Get user by id" {
        $searchResult = Get-DatabricksUsers -id $newUser.id
        $searchResult.id | Should -Be $newUser.id
    }

}
