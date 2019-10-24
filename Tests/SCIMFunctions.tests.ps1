Set-Location $PSScriptRoot
Import-Module "..\Private\SCIMFunctions.ps1" -Force

Describe "Get-DatabricksServicePrincipals"{
    
    It "Get single user"{
        $url = Get-SCIMURL -Api "Users" -id 1
        $url | Should -Be "/api/2.0/preview/scim/v2/Users/1"
    }

    It "Get all users"{
        $url = Get-SCIMURL -Api "Users"
        $url | Should -Be "/api/2.0/preview/scim/v2/Users"
    }

    It "Get single filter"{
        $url = Get-SCIMURL -Api "Users" -filters @{"filter1"=1}
        $url | Should -Be "/api/2.0/preview/scim/v2/Users?filter1=1"
    }

    It "Get multi filter"{
        $url = Get-SCIMURL -Api "Users" -filters @{"filter1"=1;"filter2"=2}
        $url.length | Should -Be 50
    }

    It "Add-SCIMValueArray"{
        (Add-SCIMValueArray "groups" "ABC", "DEF")
    }
    
}