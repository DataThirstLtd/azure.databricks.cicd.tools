<#
.SYNOPSIS
Creates Spark-Submit Job in Databricks. Script uses Databricks API 2.0 create job query: https://docs.azuredatabricks.net/api/latest/jobs.html#create  

.DESCRIPTION
Creates Spark-Submit Job in Databricks. Script uses Databricks API 2.0 create job query: https://docs.azuredatabricks.net/api/latest/jobs.html#create
If the job name exists it will be updated instead of creating a new job.

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example: northeurope

.PARAMETER JobName
Name of the job that will appear in the Job list. If a job with this name exists
it will be updated.

.PARAMETER ClusterId
The ClusterId of an existing cluster to use. Optional.

.PARAMETER SparkVersion
Spark version for cluster that will run the job. Example: 4.0.x-scala2.11
Note: Ignored if ClusterId is populated.
    
.PARAMETER NodeType
Type of worker for cluster that will run the job. Example: Standard_D3_v2.
Note: Ignored if ClusterId is populated.

.PARAMETER DriverNodeType
Type of driver for cluster that will run the job. Example: Standard_D3_v2.
If not provided the NodeType will be used.
Note: Ignored if ClusterId is populated.

.PARAMETER MinNumberOfWorkers
Number of workers for cluster that will run the job.
Note: If Min & Max Workers are the same autoscale is disabled.
Note: Ignored if ClusterId is populated.

.PARAMETER MaxNumberOfWorkers
Number of workers for cluster that will run the job.
Note: If Min & Max Workers are the same autoscale is disabled.
Note: Ignored if ClusterId is populated.

.PARAMETER Timeout
Timeout, in seconds, applied to each run of the job. If not set, there will be no timeout. 

.PARAMETER MaxRetries
An optional maximum number of times to retry an unsuccessful run. A run is considered to be unsuccessful if it completes with a FAILED result_state or INTERNAL_ERROR life_cycle_state. The value -1 means to retry indefinitely and the value 0 means to never retry. If not set, the default behavior will be never retry.

.PARAMETER ScheduleCronExpression
By default, job will run when triggered using Jobs UI or sending API request to run. You can provide cron schedule expression for job's periodic run. How to compose cron schedule expression: http://www.quartz-scheduler.org/documentation/quartz-2.1.x/tutorials/tutorial-lesson-06.html 

.PARAMETER Timezone
Timezone for Cron Schedule Expression. Required if ScheduleCronExpression provided. See here for all possible timezones: http://joda-time.sourceforge.net/timezones.html
Example: UTC

.PARAMETER NotebookPath
Path to the Notebook in Databricks that will be executed by this Job. 

.PARAMETER NotebookParameters
Optional parameters that will be provided to Notebook when Job is executed. Example: {"name":"john doe","age":"35"}

.PARAMETER Libraries
Optional. Array of json strings. Example: '{"pypi":{package:"simplejson"}}', '{"jar", "DBFS:/mylibraries/test.jar"}'

.EXAMPLE
PS C:\> Add-DatabricksNotebookJob -BearerToken $BearerToken -Region $Region -JobName "Job1" -SparkVersion "4.1.x-scala2.11" -NodeType "Standard_D3_v2" -MinNumberOfWorkers 2 -MaxNumberOfWorkers 2 -Timeout 100 -MaxRetries 3 -ScheduleCronExpression "0 15 22 ? * *" -Timezone "UTC" -NotebookPath "/Shared/Test" -NotebookParametersJson '{"key": "value", "name": "test2"}' -Libraries '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'

The above example create a job on a new cluster.
    
.NOTES
Author: Tadeusz Balcer
Extended: Simon D'Morias / Data Thirst Ltd
#>

Function Add-DatabricksSparkSubmitJob {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$JobName,
        [parameter(Mandatory = $false)][string]$ClusterId,
        [parameter(Mandatory = $false)][string]$SparkVersion,
        [parameter(Mandatory = $false)][string]$NodeType,
        [parameter(Mandatory = $false)][string]$DriverNodeType,
        [parameter(Mandatory = $false)][int]$MinNumberOfWorkers,
        [parameter(Mandatory = $false)][int]$MaxNumberOfWorkers,
        [parameter(Mandatory = $false)][int]$Timeout,
        [parameter(Mandatory = $false)][int]$MaxRetries,
        [parameter(Mandatory = $false)][string]$ScheduleCronExpression,
        [parameter(Mandatory = $false)][string]$Timezone,
        [parameter(Mandatory = $true)][string]$NotebookPath,
        [parameter(Mandatory = $false)][string]$NotebookParametersJson,
        [parameter(Mandatory = $false)][string[]]$Libraries
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")

    $ExistingJobs = Get-DatabricksJobs -BearerToken $BearerToken -Region $Region

    $ExistingJobDetail = $ExistingJobs | Where-Object {$_.settings.name -eq $JobName} | Select-Object job_id -First 1

    if ($ExistingJobDetail){
        $JobId = $ExistingJobDetail.job_id[0]
        Write-Verbose "Updating JobId: $JobId"
        $Mode = "reset"
    } 
    else{
        $Mode = "create"
    }

    $JobBody = @{}
    $JobBody['name'] = $JobName

    If ($ClusterId){
        $JobBody['existing_cluster_id'] = $ClusterId
    }
    else {
        $ClusterDetails = @{}
        $ClusterDetails['node_type_id'] = $NodeType
        $DriverNodeType = if ($PSBoundParameters.ContainsKey('DriverNodeType')) { $DriverNodeType } else { $NodeType }
        $ClusterDetails['driver_node_type_id'] = $DriverNodeType
        $ClusterDetails['spark_version'] = $SparkVersion
        If ($MinNumberOfWorkers -eq $MaxNumberOfWorkers){
            $ClusterDetails['num_workers'] = $MinNumberOfWorkers
        }
        else {
            $ClusterDetails['autoscale'] = @{"min_workers"=$MinNumberOfWorkers;"max_workers"=$MaxNumberOfWorkers}
        }
        $JobBody['new_cluster'] = $ClusterDetails
    }

    If ($PSBoundParameters.ContainsKey('Timeout')) {$JobBody['timeout_seconds'] = $Timeout}
    If ($PSBoundParameters.ContainsKey('MaxRetries')) {$JobBody['max_retries'] = $MaxRetries}
    If ($PSBoundParameters.ContainsKey('ScheduleCronExpression')) {
        $JobBody['schedule'] = @{"quartz_cron_expression"=$ScheduleCronExpression;"timezone_id"=$Timezone}
    }
    
    $Notebook = @{}
    $Notebook['notebook_path'] = $NotebookPath
    If ($PSBoundParameters.ContainsKey('NotebookParametersJson')) {
        $Notebook['base_parameters'] = $NotebookParametersJson | ConvertFrom-Json
    }

    $JobBody['notebook_task'] = $Notebook

    If ($PSBoundParameters.ContainsKey('Libraries')) {
        If ($Libraries.Count -eq 1) {
            $Libraries += '{"DummyKey":"1"}'
        }
        $JobBody['libraries'] = $Libraries | ConvertFrom-Json
    }

    If ($Mode -eq 'create'){
        $Body = $JobBody
    }
    else {
        $Body = @{}
        $Body['job_id']= $JobId
        $Body['new_settings'] = $JobBody
    }

    $BodyText = $Body | ConvertTo-Json -Depth 10
    $BodyText = Remove-DummyKey $BodyText

    Write-Verbose $BodyText
  
    Try {
        $JobDetails = Invoke-RestMethod -Method Post -Body $BodyText -Uri "https://$Region.azuredatabricks.net/api/2.0/jobs/$Mode" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    if ($Mode -eq "create") {
        Return $JobDetails.job_id
    }
    else {
        Return $JobId
    }
}