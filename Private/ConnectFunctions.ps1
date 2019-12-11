Function DatabricksTokenState{ 
    [cmdletbinding()]
    param()
    if (!($global:DatabricksTokenExpires))
    {
        return "Missing"
    }
    elseif ((Get-Date) -gt $global:DatabricksTokenExpires) {
        return "Expired"
    }
    else{
        return "Valid"
    }
}

Function ManagementTokenState{ 
    [cmdletbinding()]
    param()
    if (!($global:ManagementTokenExpires))
    {
        return "Missing"
    }
    elseif ((Get-Date) -gt $global:ManagementTokenExpires) {
        return "Expired"
    }
    else{
        return "Valid"
    }
}


Function Get-AADDatabricksToken{
    [cmdletbinding()]
    param()
    $State = DatabricksTokenState
    if ($state = "Expired" -and $global:DatabricksRefeshToken -eq $null){
        $state = "Missing"
    }

    switch ($State) {
        "Valid" { 
            Write-Verbose "AAD Databricks Token is already valid"
            return 
        }
        "Expired" {
            Write-Verbose "Refreshing AAD Databricks Token"
            $Refresh = $global:DatabricksRefeshToken
            $Body = "grant_type=refresh_token&client_id=$ApplicationId&refresh_token=$Refresh&resource=$resourceId"
            $Response = Invoke-RestMethod -Method Post -Uri $URI -Body $Body -ContentType application/x-www-form-urlencoded
        }
        "Missing" {
            Write-Verbose "Getting new AAD Databricks Token"
            $Secret = [System.Web.HttpUtility]::UrlEncode($Secret)
            $BodyText="grant_type=client_credentials&client_id=$ApplicationId&resource=2ff814a6-3304-4ab8-85cb-cd0e6f879c1d&client_secret=$Secret"
            $Response = Invoke-RestMethod -Method POST -Body $BodyText -Uri $URI -ContentType application/x-www-form-urlencoded
        }
    }
    $global:DatabricksAccessToken = $Response.access_token
    $global:DatabricksRefeshToken = $Response.refresh_token
    $global:DatabricksTokenExpires = (Get-Date).AddSeconds($Response.expires_in)
}

Function Get-AADManagementToken{
    [cmdletbinding()]
    param()
    $State = ManagementTokenState
    if ($state = "Expired" -and $global:ManagementRefreshToken -eq $null){
        $state = "Missing"
    }

    switch ($State) {
        "Valid" { 
            Write-Verbose "AAD Management Token is already valid"
            return 
        }
        "Expired" {
            Write-Verbose "Refreshing AAD Management Token"
            $Refresh = $global:ManagementRefreshToken
            $Body = "grant_type=refresh_token&client_id=$ApplicationId&refresh_token=$Refresh&resource=$resourceId"
            $Response = Invoke-RestMethod -Method Post -Uri $URI -Body $Body -ContentType application/x-www-form-urlencoded
        }
        "Missing" {
            Write-Verbose "Getting new AAD Management Token"
            $Secret = [System.Web.HttpUtility]::UrlEncode($Secret)
            $BodyText="grant_type=client_credentials&client_id=$ApplicationId&resource=https://management.core.windows.net/&client_secret=$Secret"
            $Response = Invoke-RestMethod -Method POST -Body $BodyText -Uri $URI -ContentType application/x-www-form-urlencoded
        }
    }
    $global:ManagementAccessToken = $Response.access_token
    $global:ManagementRefreshToken = $Response.refresh_token
    $global:ManagementTokenExpires = (Get-Date).AddSeconds($Response.expires_in)
}

Function Set-GlobalsNull{
    [cmdletbinding()]
    param()
    $global:DatabricksOrgId = $null
    $global:Headers = $null
    $global:DatabricksURI = $null
    
    $global:DatabricksAccessToken = $null
    $global:DatabricksRefeshToken = $null
    $global:DatabricksTokenExpires = $null

    $global:ManagementAccessToken = $null
    $global:ManagementRefreshToken = $null
    $global:ManagementTokenExpires = $null
}

Function Write-Globals{
    [cmdletbinding()]
    param()
    
    $LocalHeaders = $global:Headers | ConvertTo-Json
    Write-Verbose "Headers: $LocalHeaders"
    Write-Verbose "URI: $global:DatabricksURI"
    Write-Verbose "DatabricksOrgId: $global:DatabricksOrgId"

    Write-Verbose "DatabricksAccessToken: $global:DatabricksAccessToken"
    Write-Verbose "DatabricksRefeshToken: $global:DatabricksRefeshToken "
    Write-Verbose "DatabricksTokenExpires: $global:DatabricksTokenExpires"

    Write-Verbose "ManagementAccessToken: $global:ManagementAccessToken"
    Write-Verbose "ManagementRefreshToken: $global:ManagementRefreshToken "
    Write-Verbose "ManagementTokenExpires: $global:ManagementTokenExpires"
}