Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region


Describe "Get-DatabricksServicePrincipals"{
    
    It "Get all service princiapls"{
        $json = Get-DatabricksServicePrincipals -BearerToken $BearerToken -Region $Region 
        $Json.Count | Should -BeGreaterThan 0
    }

    It "Search for application id"{
        $json = Get-DatabricksServicePrincipals -BearerToken $BearerToken -Region $Region
        $ServicePrincipalId = $json[0].applicationid
        $json = Get-DatabricksServicePrincipals -BearerToken $BearerToken -Region $Region -ServicePrincipalId $ServicePrincipalId 
        $Json.applicationid | Should -Be $ServicePrincipalId
    }

    It "Search for application id"{
        $json = Get-DatabricksServicePrincipals -BearerToken $BearerToken -Region $Region
        $DatabricksId = $json[0].id
        $json = Get-DatabricksServicePrincipals -BearerToken $BearerToken -Region $Region -DatabricksId $DatabricksId 
        $Json.id | Should -Be $DatabricksId
    }

}
