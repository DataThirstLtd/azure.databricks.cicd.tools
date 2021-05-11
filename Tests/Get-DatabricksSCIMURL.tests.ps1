Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force

$uriTest = "/api/2.0/preview/scim/v2"

Describe "Get-DatabricksSCIMURL"{
    
    It "Called with all parameters"{
        $api = Get-DatabricksSCIMURL -Api "groups" -id "1" -filters @{"page" = 5}
        $api | Should -Be "$uriTest/groups/1?page=5"
    }

    It "Empty filter"{
        $api = Get-DatabricksSCIMURL -Api "groups" -id "1" -Filters @{}
        $api | Should -Be "$uriTest/groups/1?"
    }

    It "Empty filter and id"{
        $api = Get-DatabricksSCIMURL -Api "groups" -Filters @{}
        $api | Should -Be "$uriTest/groups/?"
    }

    It "Empty id and filter"{
        $api = Get-DatabricksSCIMURL -Api "groups" -Filters @{"page" = "4"}
        $api | Should -Be "$uriTest/groups/?page=4"
    }

    It "no filter but id"{
        $api = Get-DatabricksSCIMURL -Api "groups" -id "1" 
        $api | Should -Be "$uriTest/groups/1?"
    }

    It "no filter and no id"{
        $api = Get-DatabricksSCIMURL -Api "groups" 
        $api | Should -Be "$uriTest/groups/?"
    }


}
