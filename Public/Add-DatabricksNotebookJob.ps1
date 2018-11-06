Function Add-DatabricksNotebookJob {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$JobName,
        [parameter(Mandatory = $true)][string]$SparkVersion,
        [parameter(Mandatory = $true)][string]$NodeType,
        [parameter(Mandatory = $true)][int]$NumberOfWorkers,
        [parameter(Mandatory = $false)][int]$Timeout,
        [parameter(Mandatory = $false)][int]$MaxRetries,
        [parameter(Mandatory = $false)][string]$ScheduleCronExpression,
        [parameter(Mandatory = $false)][string]$Timezone,
        [parameter(Mandatory = $true)][string]$NotebookPath,
        [parameter(Mandatory = $false)][string]$NotebookParametersJson
    ) 
<#
.SYNOPSIS
Creates Notebook Job in Databricks. Script uses Databricks API 2.0 create job query: https://docs.azuredatabricks.net/api/latest/jobs.html#create  

.DESCRIPTION
Creates Notebook Job in Databricks. Script uses Databricks API 2.0 create job query: https://docs.azuredatabricks.net/api/latest/jobs.html#create

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example: northeurope

.PARAMETER JobName
Name of the job that will appear in the Job list

.PARAMETER SparkVersion
Spark version for cluster that will run the job. Example: 4.0.x-scala2.11
    
.PARAMETER NodeType
Type of worker for cluster that will run the job. Example: Standard_D3_v2

.PARAMETER NumberOfWorkers
Number of workers for cluster that will run the job.
    
.PARAMETER Timeout
Timeout, in seconds, applied to each run of the job. If not set, there will be no timeout. 

.PARAMETER MaxRetries
An optional maximum number of times to retry an unsuccessful run. A run is considered to be unsuccessful if it completes with a FAILED result_state or INTERNAL_ERROR life_cycle_state. The value -1 means to retry indefinitely and the value 0 means to never retry. If not set, the default behavior will be never retry.

.PARAMETER ScheduleCronExpression
By default, job will run when triggered using Jobs UI or sending API request to run. You can provide cron schedule expression for job's periodic run. How to compose cron schedule expression: http://www.quartz-scheduler.org/documentation/quartz-2.1.x/tutorials/tutorial-lesson-06.html 

.PARAMETER Timezone
Timezone for Cron Schedule Expression. Required if ScheduleCronExpression provided. See here for all possible timezones: http://joda-time.sourceforge.net/timezones.html

.PARAMETER NotebookPath
Path to the Notebook in Databricks that will be executed by this Job. 

.PARAMETER NotebookParameters
Optional paramteres that will be provided to Notebook when Job is executed. Example: {"name":"john doe","age":"35"}
    
.NOTES
Author: Tadeusz Balcer
#>

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Body = '{
        "name": "' + $JobName + '",
        "new_cluster": {
          "spark_version": "' + $SparkVersion + '",
          "node_type_id": "' + $NodeType + '",
          "num_workers": ' + $NumberOfWorkers + '
        },' +
    $(If ($PSBoundParameters.ContainsKey('Timeout')) 
    {'"timeout_seconds": ' + $Timeout + ','}) + 
    
    $(If ($PSBoundParameters.ContainsKey('MaxRetries')) 
    {'"max_retries": ' + $MaxRetries + ','}) + 
    
    $(If ($PSBoundParameters.ContainsKey('ScheduleCronExpression') -and $PSBoundParameters.ContainsKey('Timezone')) {
            '"schedule": {
                "quartz_cron_expression": "' + $ScheduleCronExpression + '",
                "timezone_id": "' + $Timezone + '"
              },
              '
        }) + 
    '"notebook_task": {
          "notebook_path": "' + $NotebookPath + '"
          ' + $(If ($PSBoundParameters.ContainsKey('NotebookParametersJson')) {
            ',"base_parameters": ' + $NotebookParametersJson
          }) + 
    '}
}'

    Try {
        Invoke-RestMethod -Method Post -Body $Body -Uri "https://$Region.azuredatabricks.net/api/2.0/jobs/create" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Error $_.ErrorDetails.Message
    }
}