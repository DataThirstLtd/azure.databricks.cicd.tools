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


Describe "Get-DatabricksServicePrincipals"{
    
    It "Get all service princiapls"{
        $json = Get-DatabricksServicePrincipals 
        $Json.Count | Should -BeGreaterThan 0
    }

    It "Search for application id"{
        $json = Get-DatabricksServicePrincipals
        $ServicePrincipalId = $json[0].applicationid
        $json = Get-DatabricksServicePrincipals -ServicePrincipalId $ServicePrincipalId 
        $Json.applicationid | Should -Be $ServicePrincipalId
    }

    It "Search for application id"{
        $json = Get-DatabricksServicePrincipals
        $DatabricksId = $json[0].id
        $json = Get-DatabricksServicePrincipals -DatabricksId $DatabricksId 
        $Json.id | Should -Be $DatabricksId
    }

}
