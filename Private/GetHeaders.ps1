
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
            }
            else {
                $Region = $null
            }

            if (DatabricksTokenState -ne "Valid"){
                Connect-Databricks -BearerToken $BearerToken -Region $Region | Out-Null
            }
        }

        return $global:Headers
    }
