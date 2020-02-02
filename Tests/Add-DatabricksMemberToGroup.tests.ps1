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

$UserName = "simon@datathirst.net"
$GroupName = "sub-acme"
$ParentName = "acme"

Describe "Add-DatabricksMemberToGroup" {
    BeforeAll{
        Add-DatabricksGroup -GroupName $ParentName
        Add-DatabricksGroup -GroupName $GroupName
    }


    It "Add User to a group"{
        $Res = Add-DatabricksMemberToGroup -Member $UserName -Parent $ParentName -Verbose
    }
    It "Add group to a group"{
        $Res = Add-DatabricksMemberToGroup -Member $GroupName -Parent $ParentName -Verbose
    }

    AfterAll{
        Remove-DatabricksGroup -GroupName $ParentName
        Remove-DatabricksGroup -GroupName $GroupName
    }
}