<#
.SYNOPSIS
Displays the job output for a specific run

.DESCRIPTION
Displays the job output for a specific run

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER RunId
The Run Id of the Job

.PARAMETER includeNoteBookOutput
When notebook returns value through dbutils.notebook.exit() api will retrieve this value. API limits this to first 5MB of output only

.EXAMPLE
PS C:\> Get-DatabricksJobRun -BearerToken $BearerToken -Region $Region

Returns all clusters

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksJobRun { 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$RunId,
        [parameter(Mandatory = $false)][switch]$includeNoteBookOutput

    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    Try {
        $Output = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/jobs/runs/get-output?run_id=$RunId" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }
    if ($PSBoundParameters.ContainsKey('includeNoteBookOutput') -eq $true) {
        return $Output
    }
    else {
        return $Output.metadata
    }
}
    