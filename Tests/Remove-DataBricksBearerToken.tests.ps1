param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="Bearer"
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


Describe "Remove-DatabricksBearerToken" {
    BeforeEach{
        $Global:Token = New-DatabricksBearerToken -LifetimeSeconds 180 -Comment "Test"
    }

    It "Delete token"{
        Remove-DatabricksBearerToken -TokenId ($Global:Token.token_info.token_id)
    }
}
