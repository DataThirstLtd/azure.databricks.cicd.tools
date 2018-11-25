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
Switch. By default Databricks allows duplicate cluster names. By setting this switch a check will be completed to see if this cluster exists.
If it does exist an error will be thrown making the script idempotent. Defaults to False.

.PARAMETER Update
Switch. If the cluster name exist then update the configuration to this one. Defaults to False.

.PARAMETER PythonVersion
2 or 3 - defaults to 2.

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

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
        [parameter(Mandatory = $false)][hashtable]$Spark_conf,
        [parameter(Mandatory = $false)][hashtable]$CustomTags,
        [parameter(Mandatory = $false)][string[]]$InitScripts,
        [parameter(Mandatory = $false)][hashtable]$SparkEnvVars,
        [parameter(Mandatory = $false)][switch]$UniqueNames,
        [parameter(Mandatory = $false)][switch]$Update,
        [parameter(Mandatory = $false)][ValidateSet(2,3)] [string]$PythonVersion=2
    ) 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken = Format-BearerToken($BearerToken)
    $Region = $Region.Replace(" ","")
    $Mode = "create"
    $Body = @{"cluster_name"=$ClusterName}
    $ClusterArgs = @{}
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
    else{
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

        $Body += GetNewClusterCluster @ClusterArgs
    }
    $BodyText = $Body | ConvertTo-Json -Depth 10
    $BodyText = Remove-DummyKey $BodyText
    Write-Verbose $BodyText
    Try {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "https://$Region.azuredatabricks.net/api/2.0/clusters/$Mode" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }
}