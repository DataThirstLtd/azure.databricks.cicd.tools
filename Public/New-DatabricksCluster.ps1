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
Spark version for cluster. Example: 5.5.x-scala2.11
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
Custom Tags to set, provide hash table of tags. Example: @{CreatedBy="SimonDM";NumOfNodes=2;CanDelete=$true}

.PARAMETER InitScripts
Init scripts to run post creation. As array of strings - paths must be full dbfs paths. Example: "dbfs:/script/script1", "dbfs:/script/script2"

.PARAMETER SparkEnvVars
A hashtable containing a set of optional, user-specified environment variable key-value pairs. Key-value pairs of the form (X,Y) are exported as is (i.e., export X='Y') while launching the driver and workers.
Example: @{SPARK_WORKER_MEMORY="29000m";SPARK_LOCAL_DIRS="/local_disk0"}

.PARAMETER Spark_conf
Hashtable. 
Example @{"spark.speculation"=$true; "spark.streaming.ui.retainedBatches"= 5}

.PARAMETER AutoTerminationMinutes
Automatically terminates the cluster after it is inactive for this time in minutes. If not set, this cluster will not be automatically terminated. 
If specified, the threshold must be between 10 and 10000 minutes. You can also set this value to 0 to explicitly disable automatic termination.

.PARAMETER UniqueNames
No longer used - cluster names are always unique, if a cluster exists with the name passed it will be updated

.PARAMETER Update
No longer used - if the cluster exists by name or id it is updated

.PARAMETER PythonVersion
2 or 3 - defaults to 3.

.PARAMETER ClusterLogPath
DBFS Location for Cluster logs - must start with dbfs:/
Example dbfs:/logs/mycluster

.PARAMETER InstancePoolId
If you would like to use nodes from an instance pool set the pool id 
https://docs.azuredatabricks.net/user-guide/instance-pools/index.html#instance-pools

.PARAMETER AzureAttributes
Hashtable. 
Example @{first_on_demand=1; availability="SPOT_WITH_FALLBACK_AZURE"; spot_bid_max_price=-1}

.PARAMETER InputObject
Pipe the contents of Get-DatabricksCluster or a json file

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function New-DatabricksCluster {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken,    
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $false)][string]$ClusterName,
        [parameter(Mandatory = $false)][string]$SparkVersion,
        [parameter(Mandatory = $false)][string]$NodeType,
        [parameter(Mandatory = $false)][string]$DriverNodeType,
        [parameter(Mandatory = $false)][int]$MinNumberOfWorkers,
        [parameter(Mandatory = $false)][int]$MaxNumberOfWorkers,
        [parameter(Mandatory = $false)][int]$AutoTerminationMinutes,
        [parameter(Mandatory = $false)][hashtable]$Spark_conf,
        [parameter(Mandatory = $false)][hashtable]$CustomTags,
        [parameter(Mandatory = $false)][string[]]$InitScripts,
        [parameter(Mandatory = $false)][hashtable]$SparkEnvVars,
        [parameter(Mandatory = $false)][switch]$UniqueNames,
        [parameter(Mandatory = $false)][switch]$Update,
        [parameter(Mandatory = $false)][ValidateSet(2,3)] [string]$PythonVersion=3,
        [parameter(Mandatory = $false)][string]$ClusterLogPath,
        [parameter(Mandatory = $false)][string]$InstancePoolId,
        [parameter(Mandatory = $false)][hashtable]$AzureAttributes,
        [parameter(ValueFromPipeline)][object]$InputObject
    ) 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    GetHeaders $PSBoundParameters | Out-Null
    
    $Body = @{}
    $ClusterArgs = @{}

    if ($InputObject){
        if ($InputObject.cluster_id -and (!(Get-DatabricksClusters -ClusterId $InputObject.cluster_id))){
            Write-Verbose "Input object contains a cluster id that does not exist - cluster will be created with a new id"
            $InputObject.PSObject.properties.remove('cluster_id')
            $Mode = "create"
        }
        elseif (($InputObject.cluster_name) -and (Get-DatabricksClusters | Where-Object {$_.cluster_name -eq $InputObject.cluster_name})){
            Write-Verbose "Cluster name provided in pipe and it exists - updating cluster"
            $Mode = "edit"
            $ClusterId = (Get-DatabricksClusters | Where-Object {$_.cluster_name -eq $InputObject.cluster_name}).cluster_id
            $ExistingClusterConfig = Get-DatabricksClusters -ClusterId $ClusterId | ConvertPSObjectToHashtable
            $Body['cluster_id'] = $ClusterId
        }
        elseif ($InputObject.cluster_id) {
            Write-Verbose "Input object contains a cluster id that exists - updating cluster"
            $Mode = "edit"
            $ClusterId = $InputObject.cluster_id
            $ExistingClusterConfig = Get-DatabricksClusters -ClusterId $ClusterId | ConvertPSObjectToHashtable
        }
        else{
            Write-Verbose "No cluster with name found - creating new cluster"
            $Mode = "create"
        }
    }
    else{
        $ExistingClusterConfig = Get-DatabricksClusters | Where-Object {$_.cluster_name -eq $ClusterName}| ConvertPSObjectToHashtable
        
        if ($ExistingClusterConfig){
            Write-Verbose "Cluster name exists - updating cluster"
            $ClusterId = $ExistingClusterConfig['cluster_id']
            $Mode = "edit"
            $Body['cluster_id'] = $ClusterId
        }
        else{
            Write-Verbose "No cluster found with this name - creating new cluster"
            $Mode = "create"
        }
    }

    $ClusterArgs['SparkVersion'] = $SparkVersion
    $ClusterArgs['NodeType'] = $NodeType
    $ClusterArgs['MinNumberOfWorkers'] = $MinNumberOfWorkers
    $ClusterArgs['MaxNumberOfWorkers'] = $MaxNumberOfWorkers
    $ClusterArgs['DriverNodeType'] = $DriverNodeType
    $ClusterArgs['AutoTerminationMinutes'] = $AutoTerminationMinutes
    $ClusterArgs['Spark_conf'] = $Spark_conf
    $ClusterArgs['CustomTags'] = $CustomTags
    $ClusterArgs['InitScripts'] = $InitScripts
    $ClusterArgs['SparkEnvVars'] = $SparkEnvVars
    $ClusterArgs['PythonVersion'] = $PythonVersion
    $ClusterArgs['ClusterLogPath'] = $ClusterLogPath
    $ClusterArgs['InstancePoolId'] = $InstancePoolId
    $ClusterArgs['AzureAttributes'] = $AzureAttributes
    $ClusterArgs['ClusterObject'] = $InputObject
    

    $Body += GetNewClusterCluster @ClusterArgs
    if ($ClusterName){
        $Body += @{"cluster_name"=$ClusterName}
    }

    if ($Mode -eq "create"){
        $Body.Remove("cluster_source")
        $Response = Invoke-DatabricksAPI -Method POST -Body $Body -API "/api/2.0/clusters/create"
        return $Response.cluster_id
    }
    if ($Mode -eq "edit"){
        $ExistingClusterConfig = RemoveClusterMeta $ExistingClusterConfig
        $CompareBody = RemoveClusterMeta $Body

        if ((HashCompare $ExistingClusterConfig $CompareBody) -gt 0){
            $Response = Invoke-DatabricksAPI -Method POST -Body $Body -API "/api/2.0/clusters/edit"
        }
        else{
            Write-Warning "Cluster unchanged - not deploying to prevent unnecessary restart of cluster"
        }
        return $ClusterId
    }
}


