Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
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