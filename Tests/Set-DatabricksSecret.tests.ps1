param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode="ServicePrincipal"
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

Describe "Set-DatabricksSecret" {
    BeforeAll{
        Remove-DatabricksSecretScope -ScopeName "Simpletestvalue"
        Remove-DatabricksSecretScope -ScopeName "JsonasSecretValue"
        Remove-DatabricksSecretScope -ScopeName "GuidasSecretValue"
        Remove-DatabricksSecretScope -ScopeName "S3asSecretValue"
        Remove-DatabricksSecretScope -ScopeName "SQLIPasSecretValue"
        Remove-DatabricksSecretScope -ScopeName "SQLasSecretValue"
    }
    It "Simple test value" {
        $ScopeName = "Simpletestvalue"
        $SecretName = "Test1"
        $SecretName2 = "Test2"
        $SecretValue = "mykey\/\/"
        $SecretValue2 = "##my_other++key"
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope | Should -Be $Null
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName2 -SecretValue $SecretValue2  -Verbose
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope.count | Should -BeExactly 1
        $secrets = Get-DatabricksSecretByScope -ScopeName $ScopeName
        $secrets.Count | Should -BeExactly 2
        Remove-DatabricksSecretScope -ScopeName $ScopeName
    }

    It "Json as Secret Value" {
        $ScopeName = "JsonasSecretValue"
        $SecretName = "TestJson"
        $SecretValue = '{\"userId\":\"uname\", \"password\": \"pword\"}'
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope | Should -Be $Null
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope.count | Should -BeExactly 1
        $secrets = Get-DatabricksSecretByScope -ScopeName $ScopeName
        $secrets.Count | Should -BeExactly 1
        Remove-DatabricksSecretScope -ScopeName $ScopeName
    }

    It "Guid as Secret Value" {
        $ScopeName = "GuidasSecretValue"
        $SecretName = "TestGuid"
        $SecretValue = 'd3684754-0fa3-46a4-92c9-cf695a109885'
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope | Should -Be $Null
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope.count | Should -BeExactly 1
        $secrets = Get-DatabricksSecretByScope -ScopeName $ScopeName
        $secrets.Count | Should -BeExactly 1
        Remove-DatabricksSecretScope -ScopeName $ScopeName
    }

    It "S3 Bucket Name as Secret Value" {
        $ScopeName = "S3asSecretValue"
        $SecretName = "TestS3"
        $SecretValue = 'confluent-kafka-connect-s3-testing'
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope | Should -Be $Null
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope.count | Should -BeExactly 1
        $secrets = Get-DatabricksSecretByScope -ScopeName $ScopeName
        $secrets.Count | Should -BeExactly 1
        Remove-DatabricksSecretScope -ScopeName $ScopeName
    }

    It "SQL Server Connection String as Secret Value" {
        $ScopeName = "SQLasSecretValue"
        $SecretName = "TestSQL"
        $SecretValue = 'Server=myServerName\myInstanceName;Database=myDataBase;User Id=myUsername;Password=myPassword;'
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope | Should -Be $Null
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope.count | Should -BeExactly 1
        $secrets = Get-DatabricksSecretByScope -ScopeName $ScopeName
        $secrets.Count | Should -BeExactly 1
        Remove-DatabricksSecretScope -ScopeName $ScopeName
    }

    It "SQL Server IP Address as Secret Value" {
        $ScopeName = "SQLIPasSecretValue"
        $SecretName = "TestSQLIP"
        $SecretValue = 'Data Source=190.190.200.100,1433;Network Library=DBMSSOCN;Initial Catalog=myDataBase;User ID=myUsername;Password=myPassword;'
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope | Should -Be $Null
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
        $scope = Get-DatabricksSecretScopes -ScopeName $ScopeName
        $scope.count | Should -BeExactly 1
        $secrets = Get-DatabricksSecretByScope -ScopeName $ScopeName
        $secrets.Count | Should -BeExactly 1
        Remove-DatabricksSecretScope -ScopeName $ScopeName
    }
}
