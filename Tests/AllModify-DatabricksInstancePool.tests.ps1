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

Describe "Add-DatabricksInstancePool Create" {
    BeforeAll{
        Get-DatabricksInstancePool -InstancePoolName "UnitTest" | Remove-DatabricksInstancePool
    }
    It "Simple add Pool"{
        $global:InstancePool = Add-DatabricksInstancePool -InstancePoolName "UnitTest" -NodeType "Standard_D3_v2" -MinIdleInstances 1 -MaxCapacity 2 -CustomTags @{CreatedBy="SimonDM";NumOfNodes=2;CanDelete=$true}
    }

}


Describe "Add-DatabricksInstancePool Edit" {
    It "Edit"{
        $global:InstancePool = Add-DatabricksInstancePool -InstancePoolName "UnitTest" -NodeType "Standard_D3_v2" -MinIdleInstances 1 -MaxCapacity 3
    }
}

Describe "Remove-DatabricksInstancePool " {
    It "Drop"{
        Get-DatabricksInstancePool -InstancePoolName "UnitTest" | Remove-DatabricksInstancePool
    }
}
