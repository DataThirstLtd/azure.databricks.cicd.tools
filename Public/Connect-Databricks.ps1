
Function Connect-Databricks {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $false)][string]$ClientId,
        [parameter(Mandatory = $false)][string]$RedirectUri="http://localhost",
        [parameter(Mandatory = $false)][string]$DatabricksOrgId,
        [parameter(Mandatory = $false)][switch]$Force
    ) 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $AzureRegion = $Region.Replace(" ","")
    $script:DatabricksURI = "https://$AzureRegion.azuredatabricks.net" 
    $authority = "https://login.windows.net/common/oauth2/authorize" 
    $resource = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

    if ($BearerToken){
        # Use Databricks Bearer Token Method
        $script:DatabricksBearerToken = "Bearer $BearerToken"
        # Basically do not expire the token
        $script:Expires = (Get-Date).AddDays(90)
    }
    else{
        if(!(Get-Package adal.ps)) { Install-Package -Name adal.ps -Scope CurrentUser }

        If ($PSBoundParameters.ContainsKey('Force')){
            Clear-ADALAccessTokenCache -AuthorityName $authority
            $script:DatabricksBearerToken = $null
            $script:Expires = $null
            $script:DatabricksOrgId = $null
        }

        if (!($script:Expires) -or ((Get-Date) -gt $script:Expires)){
            $response = Get-ADALToken -Resource $resource -ClientId $ClientId -RedirectUri $RedirectUri -Authority $authority -PromptBehavior:Auto
            $script:DatabricksBearerToken = "Bearer " + $response.$accessToken
            $script:Expires = $response.ExpiresOn
            $script:DatabricksOrgId = $DatabricksOrgId
        }

    }
}
