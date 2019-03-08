
    function GetHeaders(){
        if (!($script:Expires) -or ((Get-Date) -gt $script:Expires)){
            Throw "Not connected - run command Connect-Databricks"
        }

        $Headers = @{}
        $Headers['Authorization'] = $script:DatabricksBearerToken

        if (!($script:DatabricksOrgId)){
            $Headers['X-Databricks-Org-Id'] = $script:DatabricksOrgId
        }

        return $Headers
    }
