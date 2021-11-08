<#
.SYNOPSIS
Creates Notebook Job in Databricks. Script uses Databricks API 2.1 create job query: https://docs.azuredatabricks.net/api/latest/jobs.html#create  

.DESCRIPTION
Creates Notebook Job in Databricks. Script uses Databricks API 2.1 create job query: https://docs.azuredatabricks.net/api/latest/jobs.html#create
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
Spark version for cluster that will run the job. Example: 5.5.x-scala2.11
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

.PARAMETER PythonVersion
2 or 3 - defaults to 2.

.PARAMETER InitScripts
Init scripts to run post creation. Example: "dbfs:/script/script1", "dbfs:/script/script2"

.PARAMETER SparkEnvVars
An object containing a set of optional, user-specified environment variable key-value pairs. Key-value pairs of the form (X,Y) are exported as is (i.e., export X='Y') while launching the driver and workers.
Example: '@{SPARK_WORKER_MEMORY="29000m";SPARK_LOCAL_DIRS="/local_disk0"}

.PARAMETER Spark_conf
Hashtable. 
Example @{"spark.speculation"=$true; "spark.streaming.ui.retainedBatches"= 5}

.PARAMETER CustomTags
Custom Tags to set, provide hash table of tags. Example: @{CreatedBy="SimonDM";NumOfNodes=2;CanDelete=$true}

.PARAMETER RunImmediate
Switch.
Performs a Run Now task instead of creating a job. The process is executed immediately in an async process.
Setting this option returns a RunId.

.PARAMETER ClusterLogPath
DBFS Location for Cluster logs - must start with dbfs:/
Example dbfs:/logs/mycluster

.PARAMETER EmailAlertsOnFailure
A string of email accounts that will receive an email if the job is failed
Example "andrea.lewis@microsoft.com,maria.wood@microsoft.com"

.PARAMETER EmailAlertsOnStart
A string of email accounts that will receive an email if the job is started
Example "bob.orear@microsoft.com,bob.greenberg@microsoft.com"

.PARAMETER EmailAlertsOnSuccess
A string of email accounts that will receive an email if the job is succeeded
Example "marc.mcdonald@microsoft.com,gordon.letwin@microsoft.com"

.PARAMETER noAlertSkippedRuns
Switch.
if set, do not send email to recipients specified in on_failure if the run is skipped.


.PARAMETER MaxConcurrentRuns
Number of allowed concurrent runs of the job before databricks will skip further requests.

.PARAMETER AccessControlList
Number of allowed concurrent runs of the job before databricks will skip further requests.
Optional. Array of json strings. Example: '{"user_name": "loren.ipsum@nodomain.asdf","permission_level": "CAN_MANAGE_RUN"}', '{"group_name": "these_users","permission_level": "CAN_MANAGE"}'

.EXAMPLE
PS C:\> Add-DatabricksNotebookJob -BearerToken $BearerToken -Region $Region -JobName "Job1" -SparkVersion "5.5.x-scala2.11" -NodeType "Standard_D3_v2" -MinNumberOfWorkers 2 -MaxNumberOfWorkers 2 -Timeout 100 -MaxRetries 3 -ScheduleCronExpression "0 15 22 ? * *" -Timezone "UTC" -NotebookPath "/Shared/Test" -NotebookParametersJson '{"key": "value", "name": "test2"}' -Libraries '{"pypi":{package:"simplejson"}}', '{"jar": "DBFS:/mylibraries/test.jar"}'

The above example create a job on a new cluster.
    
Add-DatabricksNotebookJob -JobName "Job1" -SparkVersion "5.5.x-scala2.11" -NodeType "Standard_D3_v2" -MinNumberOfWorkers 2 -MaxNumberOfWorkers 2 -Timeout 100 -MaxRetries 3 -ScheduleCronExpression "0 15 22 ? * *" -Timezone "UTC" -NotebookPath "/Shared/Test" -NotebookParametersJson '{"key": "value", "name": "test2"}' -AccessControlList '{"user_name": "loren.ipsum@nodomain.asdf","permission_level": "CAN_MANAGE_RUN"}', '{"group_name": "these_users","permission_level": "CAN_MANAGE"}'

The above example creates an access control list on a new job

.NOTES
Author: Tadeusz Balcer
Extended: Simon D'Morias / Data Thirst Ltd
#>

Function Add-DatabricksNotebookJob {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,    
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$JobName,
        [parameter(ValueFromPipeline, Mandatory = $false)][object]$InputObject,
        [parameter(Mandatory = $false)][string]$ClusterId,
        [parameter(Mandatory = $false)][string]$SparkVersion,
        [parameter(Mandatory = $false)][string]$NodeType,
        [parameter(Mandatory = $false)][string]$DriverNodeType,
        [parameter(Mandatory = $false)][int]$MinNumberOfWorkers,
        [parameter(Mandatory = $false)][int]$MaxNumberOfWorkers,
        [parameter(Mandatory = $false)][int]$Timeout,
        [parameter(Mandatory = $false)][string]$EmailAlertsOnFailure,
        [parameter(Mandatory = $false)][string]$EmailAlertsOnStart,
        [parameter(Mandatory = $false)][string]$EmailAlertsOnSuccess,
        [parameter(Mandatory = $false)][switch]$noAlertSkippedRuns,
        [parameter(Mandatory = $false)][int]$MaxRetries,
        [parameter(Mandatory = $false)][string]$ScheduleCronExpression,
        [parameter(Mandatory = $false)][string]$Timezone,
        [parameter(Mandatory = $false)][string]$NotebookPath,
        [parameter(Mandatory = $false)][string]$NotebookParametersJson,
        [parameter(Mandatory = $false)][string[]]$Libraries,
        [parameter(Mandatory = $false)][ValidateSet(2, 3)] [string]$PythonVersion = 3,
        [parameter(Mandatory = $false)][hashtable]$Spark_conf,
        [parameter(Mandatory = $false)][hashtable]$CustomTags,
        [parameter(Mandatory = $false)][string[]]$InitScripts,
        [parameter(Mandatory = $false)][hashtable]$SparkEnvVars,
        [parameter(Mandatory = $false)][switch]$RunImmediate,
        [parameter(Mandatory = $false)][string]$ClusterLogPath,
        [parameter(Mandatory = $false)][string]$InstancePoolId,
        [parameter(Mandatory = $false)][int]$MaxConcurrentRuns,
        [parameter(Mandatory = $false)][string[]]$AccessControlList
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    $ExistingJobs = Get-DatabricksJobs -BearerToken $BearerToken -Region $Region

    $ExistingJobDetail = $ExistingJobs | Where-Object { $_.settings.name -eq $JobName } | Select-Object job_id -First 1

    if (($ExistingJobDetail) -and (!($RunImmediate.IsPresent))) {
        $JobId = $ExistingJobDetail.job_id[0]
        Write-Verbose "Updating JobId: $JobId"
        $Mode = "update"
    } 
    else {
        $Mode = "create"
    }
 
    if ($PSBoundParameters.ContainsKey('InputObject') -eq $false) {
        $JobBody = @{ }   
        if ($RunImmediate.IsPresent) {
            $JobBody['run_name'] = $JobName
        }
        else {
            $JobBody['name'] = $JobName
        }

        If ($ClusterId) {
            $JobBody['existing_cluster_id'] = $ClusterId
        }
        else {
            $ClusterArgs = @{ }
            $ClusterArgs['SparkVersion'] = $SparkVersion
            $ClusterArgs['NodeType'] = $NodeType
            $ClusterArgs['MinNumberOfWorkers'] = $MinNumberOfWorkers
            $ClusterArgs['MaxNumberOfWorkers'] = $MaxNumberOfWorkers
            $ClusterArgs['DriverNodeType'] = $DriverNodeType
            $ClusterArgs['Spark_conf'] = $Spark_conf
            $ClusterArgs['CustomTags'] = $CustomTags
            $ClusterArgs['InitScripts'] = $InitScripts
            $ClusterArgs['SparkEnvVars'] = $SparkEnvVars
            $ClusterArgs['PythonVersion'] = $PythonVersion
            $ClusterArgs['ClusterLogPath'] = $ClusterLogPath
            $ClusterArgs['InstancePoolId'] = $InstancePoolId

            $JobBody['new_cluster'] = (GetNewClusterCluster @ClusterArgs)
        }

        If ($PSBoundParameters.ContainsKey('Timeout')) { $JobBody['timeout_seconds'] = $Timeout }
        If ($PSBoundParameters.ContainsKey('MaxRetries')) { $JobBody['max_retries'] = $MaxRetries }
        If ($PSBoundParameters.ContainsKey('MaxConcurrentRuns')) { $JobBody['max_concurrent_runs'] = $MaxConcurrentRuns }
        If ($PSBoundParameters.ContainsKey('ScheduleCronExpression')) {
            $JobBody['schedule'] = @{"quartz_cron_expression" = $ScheduleCronExpression; "timezone_id" = $Timezone }
        }


        If ($PSBoundParameters.ContainsKey('EmailAlertsOnStart')) {
            $JobBody['email_notifications'] = @{"on_start" = $EmailAlertsOnStart }
        }

        If ($PSBoundParameters.ContainsKey('EmailAlertsOnSuccess')) {
            If ($PSBoundParameters.ContainsKey('EmailAlertsOnStart')) {
                $JobBody['email_notifications'].Add("on_success", $EmailAlertsOnSuccess)
            }
            else {
                $JobBody['email_notifications'] = @{"on_success" = $EmailAlertsOnSuccess }
            }
        }

        If ($PSBoundParameters.ContainsKey('EmailAlertsOnFailure')) {
            If ($PSBoundParameters.ContainsKey('EmailAlertsOnSuccess') -or $PSBoundParameters.ContainsKey('EmailAlertsOnStart')) {
                $JobBody['email_notifications'].Add("on_failure", $EmailAlertsOnFailure)
            }
            else {
                $JobBody['email_notifications'] = @{"on_failure" = $EmailAlertsOnFailure }
            }
        }

        If ($PSBoundParameters.ContainsKey('AccessControlList')) {
            $JobBody['access_control_list'] = $AccessControlList | ConvertFrom-Json
        }

        if ($noAlertSkippedRuns.IsPresent) {
            $JobBody['email_notifications'].Add("no_alert_for_skipped_runs", $true)
        }

        $Notebook = @{ }
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
    }
    else {
        $jobBody = $InputObject
    }

    If ($Mode -eq 'create') {
        $Body = $JobBody
    }
    else {
        $Body = @{ }
        $Body['job_id'] = $JobId
        $Body['new_settings'] = $JobBody
    }

    $BodyText = $Body | ConvertTo-Json -Depth 10
    $BodyText = Remove-DummyKey $BodyText

    Write-Verbose $BodyText
  
    Try {
        if ($RunImmediate.IsPresent) {
            $Url = "jobs/runs/submit"
        }
        else {
            $Url = "jobs/$Mode"
        }   
        $JobDetails = Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.1/$Url" -Headers $Headers
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }
    
    if ($RunImmediate.IsPresent) {
        Return $JobDetails.run_id
    }
    else {
        if ($Mode -eq "create") {
            Return $JobDetails.job_id
        }
        else {
            Return $JobId
        }
    }   
}
