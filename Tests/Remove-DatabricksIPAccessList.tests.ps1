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


Describe "Remove-DatabricksIPAccessList" {

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

        Set-DatabricksIPAccessListStatus -enabled $true
        Add-DatabricksIPAccessList -ListName $name -ListType 'ALLOW' -ListIPs  $myIP
    }

    AfterAll {
        Set-DatabricksIPAccessListStatus -enabled $false
    }

    It "Remove all access IP" {
        $accessList = Get-DatabricksIPAccessList
        foreach ($item in $accessList) {
            Remove-DatabricksIPAccessList -ListID $item.list_id
        }

        $accessList = Get-DatabricksIPAccessList
        $accessList.Count | Should -Be 0
    }
}
  