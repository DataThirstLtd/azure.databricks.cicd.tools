
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

            if ($BearerToken -and $Region){
                Connect-Databricks -BearerToken $BearerToken -Region $Region | Out-Null
            }
            elseif ((DatabricksTokenState) -ne "Valid"){
                Throw "You are not connected - please execute Connect-Databricks"
            }
        }

        return $global:Headers
    }
