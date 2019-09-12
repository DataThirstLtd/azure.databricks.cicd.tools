Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region
$UserName = "simon@datathirst.net"
$GroupName = "sub-acme"
$ParentName = "acme"

Describe "Add-DatabricksMemberToGroup" {
    BeforeAll{
        Add-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $ParentName
        Add-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $GroupName
    }


    It "Add User to a group"{
        $Res = Add-DatabricksMemberToGroup -BearerToken $BearerToken -Region $Region -Member $UserName -Parent $ParentName -Verbose
    }
    It "Add group to a group"{
        $Res = Add-DatabricksMemberToGroup -BearerToken $BearerToken -Region $Region -Member $GroupName -Parent $ParentName -Verbose
    }

    AfterAll{
        Remove-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $ParentName
        Remove-DatabricksGroup -BearerToken $BearerToken -Region $Region -GroupName $GroupName
    }
}