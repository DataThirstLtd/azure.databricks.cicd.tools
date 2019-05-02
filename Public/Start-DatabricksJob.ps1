<#
.SYNOPSIS
Starts a Databricks Job by id or name.

.DESCRIPTION
Starts a Databricks Job by id or name.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER JobId
Optional. Will start Job with this Id.

.PARAMETER JobName
Optional. Start Job(s) matching this name (note that names are not unique in Databricks)

.PARAMETER PythonParameters
Optional. Array for parameters for job, for example "--pyFiles", "dbfs:/myscript.py", "myparam"

.PARAMETER JarParameters
Optional. Array for parameters for job, for example "--pyFiles", "dbfs:/myscript.py", "myparam"

.PARAMETER SparkSubmitParameters
Optional. Array for parameters for job, for example "--pyFiles", "dbfs:/myscript.py", "myparam"

.PARAMETER NotebookParameters
Optional. Parameters that will be provided to Notebook when Job is executed. Example: {"name":"john doe","age":"35"}

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Start-DatabricksJob {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,    
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $false)][string]$JobName,
        [parameter(Mandatory = $false)][string]$JobId,
        [parameter(Mandatory = $false)][string[]]$PythonParameters,
        [parameter(Mandatory = $false)][string[]]$JarParameters,
        [parameter(Mandatory = $false)][string[]]$SparkSubmitParameters,
        [parameter(Mandatory = $false)][string]$NotebookParametersJson
        )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 

    $body = @{}
    $JobIds = @()

    If ($PSBoundParameters.ContainsKey('JobId')) {
        $JobIds += $JobId
    }
    elseif ($PSBoundParameters.ContainsKey('JobName')) {
        $Jobs = (Get-DatabricksJobs -Bearer $BearerToken -Region $Region | Where-Object {$_.settings.name -eq $JobName})
        foreach ($c in $Jobs)
        {
            $JobIds += $c.job_id
        }
    }
    else{
        Write-Error "You must specify JobId or JobName"
        return
    }

    foreach ($JobId in $JobIds)
    {
        $Body['job_id'] = $JobId
        If (($PSBoundParameters.ContainsKey('PythonParameters')) -and ($null -ne $PythonParameters)) {
            If ($PythonParameters.Count -eq 1) {
                $PythonParameters += '{"DummyKey":"1"}'
            }
            $Body['python_params'] = $PythonParameters
        }

        If (($PSBoundParameters.ContainsKey('JarParameters')) -and ($null -ne $JarParameters)) {
            If ($JarParameters.Count -eq 1) {
                $JarParameters += '{"DummyKey":"1"}'
            }
            $Body['jar_params'] = $JarParameters
        }

        If (($PSBoundParameters.ContainsKey('SparkSubmitParameters')) -and ($null -ne $SparkSubmitParameters)) {
            If ($SparkSubmitParameters.Count -eq 1) {
                $SparkSubmitParameters += '{"DummyKey":"1"}'
            }
            $Body['spark_submit_params'] = $SparkSubmitParameters
        }

        If ($PSBoundParameters.ContainsKey('NotebookParametersJson')) {
            $Body['notebook_parameters'] = $NotebookParametersJson | ConvertFrom-Json
        }
    
        Try {
            $BodyText = $Body | ConvertTo-Json -Depth 10
            Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/jobs/run-now" -Headers $Headers
        }
        Catch {
            Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
            Write-Output $_.Exception
            Write-Error $_.ErrorDetails.Message
            Return
        }
    }
}