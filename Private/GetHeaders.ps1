
    function GetHeaders($Params){

        If ($null -ne $Params){
            If ($Params.ContainsKey('BearerToken')) {
                $BearerToken = $Params['BearerToken']
            }
            else {
                $BearerToken = $null
            }

            If ($Params.ContainsKey('Region')) {
                $Region = $Params['Region']
                $Region = $Region.Replace(" ","")
            }
            else {
                $Region = $null
            }

            if (!($global:Expires) -or ((Get-Date) -gt $global:Expires)){
                Connect-Databricks -BearerToken $BearerToken -Region $Region | Out-Null
            }
        }

        $Headers = @{}
        $Headers['Authorization'] = $global:DatabricksBearerToken

        if ($global:DatabricksOrgId){
            $Headers['X-Databricks-Org-Id'] = $global:DatabricksOrgId
        }

        return $Headers
    }
