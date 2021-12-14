param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "Bearer"
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

$ScopeName = "DataThirstTest123"

Describe "Remove-DatabricksSecretScope" {
    Context "Remove a Secret Scope and do not fail if secret scope does not exist." {
        BeforeAll {
            Add-DatabricksSecretScope -ScopeName $ScopeName  -Verbose
        }
        It "Simple addition" {
            Remove-DatabricksSecretScope -ScopeName $ScopeName  -Verbose
        }

        It "Delete non existent should not fail" {
            Remove-DatabricksSecretScope -ScopeName "Doesnt exist"  -Verbose
        }

    }

    Context "Remove an empty Secret Scope." {
        BeforeEach {
            Add-DatabricksSecretScope -ScopeName $ScopeName  -Verbose
        }
        It "Remove Empty Only does not fail" {
            Remove-DatabricksSecretScope -ScopeName $ScopeName -RemoveEmptyOnly -Verbose
        }
        It "Remove Empty Only does not fail if FailOnNotExist included" {
            { Remove-DatabricksSecretScope -ScopeName $ScopeName -RemoveEmptyOnly -Verbose -FailOnNotExist } | Should Not Throw
        }
    }

    Context "Remove Secret Scope" {
        It "Remove Empty Only does not fail if FailNotExist included" {
            { 
                Add-DatabricksSecretScope -ScopeName $ScopeName  -Verbose
                Remove-DatabricksSecretScope -ScopeName $ScopeName -RemoveEmptyOnly -Verbose -FailOnNotExist } | Should Not Throw
        }
        It "Remove Scope does throw if FailOnNotExist included and scope does not exist" {
            { Remove-DatabricksSecretScope -ScopeName $ScopeName -RemoveEmptyOnly -Verbose -FailOnNotExist } | Should Throw
        }
    }

    Context "Removing Non Empty Scopes." {
        BeforeEach {
            Add-DatabricksSecretScope -ScopeName $ScopeName  -Verbose
            Set-DatabricksSecret -ScopeName $ScopeName -SecretName 'TestSecretName' -SecretValue 'ohdear'
            Set-DatabricksSecret -ScopeName $ScopeName -SecretName 'AnotherTestSecretName' -SecretValue 'ohdear'
        }
        It "Remove non-empty Scope does not fail" {
            Remove-DatabricksSecretScope -ScopeName $ScopeName -Verbose
        }
        It "Remove non-empty Scope does fail" {
            { Remove-DatabricksSecretScope -ScopeName $ScopeName -RemoveEmptyOnly -Verbose } | Should Throw
        }
        AfterAll {
            Remove-DatabricksSecretScope -ScopeName $ScopeName -Verbose
        }
    }
}
