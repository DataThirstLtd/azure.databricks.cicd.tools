Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$UserName = "user@example.com"
$GroupName = "sub-acme"
$ParentName = "acme"

Describe "Add-DatabricksSecretScope" {
    It "Add User to a group"{
        $Res = Add-DatabricksMemberToGroup -BearerToken $BearerToken -Region $Region -Member $UserName -ParentName $ParentName -Verbose
    }
    It "Add group to a group"{
        $Res = Add-DatabricksMemberToGroup -BearerToken $BearerToken -Region $Region -Member $GroupName -ParentName $ParentName -Verbose
    }
}