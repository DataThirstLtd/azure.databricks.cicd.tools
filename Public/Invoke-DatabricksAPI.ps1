<#
.SYNOPSIS
Execute any Databricks API directly, it will authenticate for you. Useful where a PowerShell command has not been created yet

.DESCRIPTION
Execute any Databricks API directly, it will authenticate for you. Useful where a PowerShell command has not been created yet

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER API
Databricks REST API to Call

.PARAMETER Body
Hashtable to pass: For example @{clusterId="abc-123";name="bob"}

.EXAMPLE
PS C:\> Invoke-DatabricksAPI -BearerToken $BearerToken -Region $Region -API "api/2.0/clusters/list" -Method GET

Returns all clusters

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Invoke-DatabricksAPI
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName='Bearer')]
        [parameter(Mandatory = $false, ParameterSetName='AAD')]
        [string]$Region,
        
        [parameter(Mandatory = $true)] [string]$API,
        [parameter(Mandatory = $false)] [hashtable]$Body,
        [parameter(Mandatory = $false)] [ValidateSet('POST','GET','DELETE','PATCH', 'PUT')] [string]$Method="GET",
        [parameter(ValueFromPipeline)][object]$InputObject
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Removing first slash if any
    if ($API.Substring(0,1) -eq "/"){
        $API = $API.Substring(1)
    }

    $Headers = GetHeaders $PSBoundParameters

    if ($InputObject){
        # InputObject provider then overwrite body
        $InputObject.PSObject.properties | ForEach-Object { $Body[$_.Name] = $_.Value }
    }
    
    try{
        if ($Body){
            $BodyText = $Body | ConvertTo-Json -Depth 10
            $Response = Invoke-RestMethod -Method $Method -Uri "$global:DatabricksURI/$API" -Headers $Headers -Body $BodyText
        }
        else{
            $Response = Invoke-RestMethod -Method $Method -Uri "$global:DatabricksURI/$API" -Headers $Headers
        }
        return $Response
    }
    catch{
        $ErrorCode = $_.Exception.Response.StatusCode.value__ 
        $Msg = $_.ErrorDetails.Message
        Write-Error "Response Code: $ErrorCode. Message: $Msg"
        throw $_
    }
    
    
}
