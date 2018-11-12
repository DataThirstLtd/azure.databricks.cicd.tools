Function New-DatabricksCluster {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken,    
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$ClusterName,
        [parameter(Mandatory = $true)][string]$SparkVersion,
        [parameter(Mandatory = $true)][string]$NodeType,
        [parameter(Mandatory = $false)][string]$DriverNodeType,
        [parameter(Mandatory = $true)][int]$MinNumberOfWorkers,
        [parameter(Mandatory = $true)][int]$MaxNumberOfWorkers,
        [parameter(Mandatory = $false)][int]$AutoTerminationMinutes,
        [parameter(Mandatory = $false)][string]$Spark_conf,
        [parameter(Mandatory = $false)][string[]]$CustomTags,
        [parameter(Mandatory = $false)][string[]]$InitScripts,
        [parameter(Mandatory = $false)][string[]]$SparkEnvVars,
        [parameter(Mandatory = $false)][switch]$UniqueNames,
        [parameter(Mandatory = $false)][switch]$Update,
        [parameter(Mandatory = $false)][ValidateSet(2,3)] [string]$PythonVersion=2
    ) 

<#
.SYNOPSIS
Creates a new Databricks cluster

.DESCRIPTION
Creates a new cluster

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER SparkVersion
Spark version for cluster. Example: 4.0.x-scala2.11
See Get-DatabricksSparkVersions
    
.PARAMETER NodeType
Type of worker for cluster. Example: Standard_D3_v2
See Get-DatabricksNodeTypes

.PARAMETER DriverNodeType
Type of Driver for cluster. Example: Standard_D3_v2. If not set it will default to $NodeType
See Get-DatabricksNodeTypes

.PARAMETER MinNumberOfWorkers
Min number of workers for cluster that will run the job. If the same as $MaxNumberOfWorkers autoscale is disabled.

.PARAMETER MaxNumberOfWorkers
Max number of workers for cluster that will run the job. If the same as $MinNumberOfWorkers autoscale is disabled.

.PARAMETER CustomTags
Custom Tags to set, provide key value pair array as Json string. Example: '{"key": "CreatedBy", "value": "simon"}', '{"key":"Date","value":"1st Jan 2000"}'

.PARAMETER InitScripts
Init scripts to run post creation. Example: '{"key": "Script1", "value": "dbfs:/script/script1"}', '{"key":"Script2","value":"dbfs:/script/script2"}'

.PARAMETER SparkEnvVars
An object containing a set of optional, user-specified environment variable key-value pairs. Key-value pairs of the form (X,Y) are exported as is (i.e., export X='Y') while launching the driver and workers.
Example: '{"key": "SPARK_WORKER_MEMORY", "value": "28000m"}', '{"key":"SPARK_LOCAL_DIRS","value":"/local_disk0"}'

.PARAMETER AutoTerminationMinutes
Automatically terminates the cluster after it is inactive for this time in minutes. If not set, this cluster will not be automatically terminated. 
If specified, the threshold must be between 10 and 10000 minutes. You can also set this value to 0 to explicitly disable automatic termination.

.PARAMETER UniqueNames
Switch. By default Databricks allows duplicate cluster names. By setting this switch a check will be completed to see if this cluster exists.
If it does exist an error will be thrown making the script idempotent. Defaults to False.

.PARAMETER Update
Switch. If the cluster name exist then update the configuration to this one. Defaults to False.


.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")
    $Mode = "create"
    
    $Body = @{"cluster_name"=$ClusterName}

    If ($UniqueNames)
    {
        $ClusterId = (Get-DatabricksClusters -Bearer $BearerToken -Region $Region | Where-Object {$_.cluster_name -eq $ClusterName})
        if ($ClusterId){
            if ($Update){
                $Mode = "edit"
                $Body['cluster_id'] = $ClusterId.cluster_id
                Write-Warning "Cluster already exists - it will be updated to this configuration"
            }
            else
            {
                Write-Error "Cluster with name $ClusterName already exists. Change name or remove -UniqueNames"
                return
            }
        }

    }
    
    $Body['spark_version'] = $SparkVersion
    $Body['spark_conf'] = $Spark_conf | ConvertFrom-Json
    $Body['node_type_id'] = $NodeType
    If ($PSBoundParameters.ContainsKey('DriverNodeType')) { $Body['driver_node_type_id'] = $DriverNodeType }
    If ($MinNumberOfWorkers -eq $MaxNumberOfWorkers){
        $Body['num_workers'] = $MinNumberOfWorkers
    }
    else {
        $Body['autoscale'] = @{"min_workers"=$MinNumberOfWorkers;"max_workers"=$MaxNumberOfWorkers}
    }

    If ($PSBoundParameters.ContainsKey('CustomTags')) {
        If ($CustomTags.Count -eq 1) {
            $CustomTags += '{"DummyKey":"1"}'
        }
        $CustomTags2 = $CustomTags | ConvertFrom-Json
        $Body['custom_tags'] = $CustomTags2
    }

    If ($PSBoundParameters.ContainsKey('InitScripts') -and (!($InitScripts -eq $null))) {
        If ($InitScripts.Count -eq 1) {
            $InitScripts += '{"DummyKey":"1"}'
        }
        $InitScripts2 = $InitScripts | ConvertFrom-Json
        $Body['init_scripts'] = $InitScripts2
    }

    If ($PSBoundParameters.ContainsKey('AutoTerminationMinutes')) {$Body['autotermination_minutes'] = $AutoTerminationMinutes}

    If ($PythonVersion -eq 3){
        $SparkEnvVars += '{"key":"PYSPARK_PYTHON","value":"/databricks/python3/bin/python3"}'
    }

    If ($SparkEnvVars.Count -gt 0) {
        If ($SparkEnvVars.Count -eq 1) {
            $SparkEnvVars += '{"DummyKey":"1"}'
        }
        $SparkEnvVars2 =  $SparkEnvVars | ConvertFrom-Json 
        $Body['spark_env_vars'] = $SparkEnvVars2
    }
    Try {
        $BodyText = $Body | ConvertTo-Json -Depth 10
        $BodyText = Remove-DummyKey($BodyText)
        Write-Verbose $BodyText
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "https://$Region.azuredatabricks.net/api/2.0/clusters/$Mode" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    

}