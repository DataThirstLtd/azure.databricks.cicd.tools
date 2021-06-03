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
        Set-DatabricksIPAccessListStatus -enabled $false
    }

    It "Can't provide unexpected ListType value" {
        try {
            Add-DatabricksIPAccessList -ListName "test" -ListType 'FOO' -ListIPs  $myIP
        }
        catch {
            $errorThrown = $true
        }

        $errorThrown | Should -Be $true
    }

    It "Can add a single IP access list" {
        $name = "testList" + (Get-Random)
        $response = Add-DatabricksIPAccessList -ListName $name -ListType 'ALLOW' -ListIPs  $myIP

        $response.label | Should -Be $name
    }

    It "Can add an array of IP access list" {
        $name = "testList" + (Get-Random)
        $ips = $myIP, "127.0.0.1"
        $response = Add-DatabricksIPAccessList -ListName $name -ListType 'ALLOW' -ListIPs $ips

        $response.address_count | Should -Be 2
    }
}
  