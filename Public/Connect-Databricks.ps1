
Function Connect-Databricks {  
    [cmdletbinding(DefaultParameterSetName='Bearer')]
    param (
        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [string]$BearerToken,

        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [parameter(Mandatory = $true, ParameterSetName='AAD')]
        [string]$Region,

        [parameter(Mandatory = $true, ParameterSetName='AAD')]
        [string]$ClientId,
        [parameter(Mandatory = $false, ParameterSetName='AAD')]
        [string]$RedirectUri="http%3A%2F%2Flocalhost",
        [parameter(Mandatory = $true, ParameterSetName='AAD')]
        [string]$DatabricksOrgId,
        [parameter(Mandatory = $true, ParameterSetName='AAD')]
        [string]$TenantId,
        [parameter(Mandatory = $false, ParameterSetName='AAD')]
        [switch]$Force
    ) 

    Write-Verbose "Globals at start of Connect:" 
    Write-Verbose "DatabricksBearerToken: $global:DatabricksBearerToken"
    Write-Verbose "RefeshToken: $global:RefeshToken "
    Write-Verbose "DatabricksOrgId: $global:DatabricksOrgId "
    Write-Verbose "Expires: $global:Expires"

    if ($Force){
        Write-Verbose "-Force set - clearing global variables"
        $global:Expires = $null
        $global:DatabricksOrgId = $null
        $global:RefeshToken = $null
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $AzureRegion = $Region.Replace(" ","")
    $global:DatabricksURI = "https://$AzureRegion.azuredatabricks.net" 
    $resourceId = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
    $URI = "https://login.microsoftonline.com/$tenantId/oauth2/token/"

    if ($BearerToken){
        # Use Databricks Bearer Token Method
        $global:DatabricksBearerToken = "Bearer $BearerToken"
        # Basically do not expire the token
        $global:Expires = (Get-Date).AddDays(90)
        $global:DatabricksOrgId = $null
        $global:RefeshToken = $null
    }
    else{
        try{
            # We have a token and it is not expired
            if (($global:Expires -and ((Get-Date) -lt  $global:Expires))){
                Write-Verbose "AAD Token is valid"
            }
            # Token has expired - try to refresh
            else{
                if (($global:Expires) -and ((Get-Date) -gt $global:Expires)){
                    Write-Verbose "Refreshing Token"
                    $Refresh = $global:RefeshToken
                    $Body = "grant_type=refresh_token&client_id=$ClientID&redirect_uri=$RedirectUri&refresh_token=$Refresh&resource=$resourceId"
                    $Response = Invoke-RestMethod -Method Post -Uri $URI -Body $Body -ContentType application/x-www-form-urlencoded
                }
                elseif (!($global:Expires)){
                    # Get Access Code
                    $ManualURL = "https://login.microsoftonline.com/$TenantId/oauth2/authorize?client_id=$ClientId&response_type=code&redirect_url=$RedirectUri&response_mode=query&resource=$ResourceId&state=987654321"
                    $code = Read-Host "Please open the URL $ManualURL in your browser - copy the code from the * URL RESPONSE * and paste the code here"
                    
                    # In case they entered the full URL try and find the code
                    if ($code -like "http*"){
                        $Start = $code.IndexOf("?code=") + 6
                        $Start
                        $End = $code.IndexOf("&", $Start) 
                        $code = $code.Substring($Start,$End-$Start)
                    }

                    # Get Token
                    Write-Verbose "Getting Token"
                    $BodyText="grant_type=authorization_code&client_id=$clientId&code=$code&redirect_uri=$redirectUri&resource=$resourceId"
                    $Response = Invoke-RestMethod -Method Post -Body $BodyText -Uri $URI -ContentType application/x-www-form-urlencoded
                }

                $global:DatabricksBearerToken = "Bearer " + $Response.access_token
                $global:RefeshToken = $Response.refresh_token
                $global:DatabricksOrgId = $DatabricksOrgId
                # Refresh in 15 minutes
                $global:Expires = (Get-Date).AddMinutes(15)
            }
        }
        catch{
            Write-Verbose "Error"
            Write-Error $_
            $global:Expires = $null
            $global:DatabricksOrgId = $null
            $global:RefeshToken = $null
        }
    }

    Write-Verbose "Globals at end of Connect:" 
    Write-Verbose "DatabricksBearerToken: $global:DatabricksBearerToken"
    Write-Verbose "RefeshToken: $global:RefeshToken "
    Write-Verbose "DatabricksOrgId: $global:DatabricksOrgId "
    Write-Verbose "Expires: $global:Expires"
}
