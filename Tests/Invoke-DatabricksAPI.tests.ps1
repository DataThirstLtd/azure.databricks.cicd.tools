Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)
$BearerToken = $Config.BearerToken
$Region = $Config.Region

$global:Expires = $null
$global:DatabricksOrgId = $null
$global:RefeshToken = $null
$global:jobs 

Describe "Invoke-DatabricksAPI" {
    it "Get Clusters"{
        $Clusters = Invoke-DatabricksAPI -BearerToken $BearerToken -Region $Region -API "api/2.0/clusters/list" -Method GET

    }

    it "with double slash"{
        $Clusters = Invoke-DatabricksAPI -BearerToken $BearerToken -Region $Region -API "/api/2.0/clusters/list" -Method GET

    }

    it "post secret"{
        $Body = @{scope= "TestScope";key="SecretName"; string_value="MySecret"}
        $Post = Invoke-DatabricksAPI -BearerToken $BearerToken -Region $Region -API "/api/2.0/secrets/put" -Method POST -Body $Body
    }
}

