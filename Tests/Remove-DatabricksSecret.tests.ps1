param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="Bearer"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($Mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

$ScopeName = "TestRemove"
$SecretName = "Test"
$SecretValue = "mykey"


Describe "Set-DatabricksSecret" {
    BeforeEach{
        Set-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -SecretValue $SecretValue  -Verbose
    }
    It "Simple test value" {
        Remove-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -Verbose
    }
    
    It "Include switch to fail if not exist" {
        { Remove-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -Verbose -FailOnNotExist } | Should Not Throw
    }
}

Describe "Remove_secRetThatDoesNotExist" {
    It "Does not throw if secret does not exist" {
        { Remove-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -Verbose } |Should Not Throw
    }

    It "Does throw if secret does not exist" {
        {Remove-DatabricksSecret -ScopeName $ScopeName -SecretName $SecretName -Verbose -FailOnNotExist} | Should Throw
    }
}
