<#
.SYNOPSIS
Returns the asettings and status of the run

.DESCRIPTION
Returns the asettings and status of the run

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER RunId
ID for the Run to check

.PARAMETER StateOnly
Switch. Resturn only the job status field. Normally returns the complete job settings & status.

.EXAMPLE
PS C:\> Get-DatabricksRun -BearerToken $BearerToken -Region $Region -RunId 10


.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksRun
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$RunId,
        [parameter(Mandatory = $false)][switch]$StateOnly
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    Try {
        $Run = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/jobs/runs/get?run_id=$RunId" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    if($StateOnly.IsPresent){
        Return $Run.state.result_state
    }
    else{
        Return $Run
    }
    
}
    