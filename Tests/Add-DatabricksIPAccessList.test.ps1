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


Describe "Add-DatabricksIPAccessList" {

    BeforeAll {
        $name = "testList" + (Get-Random)

        $sites = @('https://api.ipify.org', 'https://ifconfig.me/ip', 'https://ipinfo.io')
        $myIP = foreach ($site in $sites) {
            $return = Invoke-RestMethod -Uri $site
            $ip = ([IPAddress] $return).IPAddressToString
            if ($ip) {
                $ip
                break
            }
        }
    }

    AfterAll {
        Set-DatabricksIPAccessList -enabled $false
    }

    It "Can't provide unexpected ListType value" {
        try {
            Add-DatabricksIPAccessList -ListName $name -ListType 'FOO' -ListIPs  $myIP
        }
        catch {
            $errorThrown = $true
        }

        $errorThrown | Should -Be $true
    }

    It "Can add a IP access list" {

        $response = Add-DatabricksIPAccessList -ListName $name -ListType 'ALLOW' -ListIPs  $myIP

        $response.label | Should -Be $name
    }
}
  