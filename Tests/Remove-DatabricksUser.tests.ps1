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


Describe "Remove-DatabricksUser" {
    BeforeAll {
        $userName = "myUser" + (Get-Random) + "@foo.com" 
        $user = Add-DatabricksUser -BearerToken $BearerToken -Region $Region -Username $userName
    }

    It "Remove user" {
        Remove-DatabricksUser -UserId $user.Id

        $searchResult = Get-DatabricksUsers 
        $user = $searchResult.Resources | where-object { $_.id -eq $user.id }
        $user | should -BeNullOrEmpty
    }


}
