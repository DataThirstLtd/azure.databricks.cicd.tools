param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

Describe "Invoke-DatabricksAPI" {
    it "Get Clusters"{
        $Clusters = Invoke-DatabricksAPI -API "api/2.0/clusters/list" -Method GET

    }

    it "with double slash"{
        $Clusters = Invoke-DatabricksAPI -API "/api/2.0/clusters/list" -Method GET

    }

    it "post secret"{
        $Body = @{scope= "TestScope";key="SecretName"; string_value="MySecret"}
        $Post = Invoke-DatabricksAPI -API "/api/2.0/secrets/put" -Method POST -Body $Body
    }
}

