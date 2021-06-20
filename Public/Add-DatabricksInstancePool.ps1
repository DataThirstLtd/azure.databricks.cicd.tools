<#
.SYNOPSIS
Creates a new Databricks cluster

.DESCRIPTION
Creates a new cluster

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER InstancePoolName
The name of the instance pool. This is required for create and edit operations. It must be unique, non-empty, and less than 100 characters.
NOTE: If the instance pool name exist the instance pool will be updated
    
.PARAMETER MinIdleInstances
The minimum number of idle instances maintained by the pool. This is in addition to any instances in use by active clusters.

.PARAMETER MaxCapacity
The maximum number of instances the pool can contain, including both idle instances and ones in use by clusters. Once the maximum capacity is reached, you cannot create new clusters from the pool and existing clusters cannot autoscale up until some instances are made idle in the pool via cluster termination or down-scaling.

.PARAMETER NodeType
The node type for the instances in the pool. All clusters attached to the pool inherit this node type and the pool’s idle instances are allocated based on this type. You can retrieve a list of available node types by using the List Node Types API call.

.PARAMETER CustomTags
Additional tags for instance pool resources. Azure Databricks tags all pool resources (e.g. VM disk volumes) with these tags in addition to default_tags.

Azure Databricks allows up to 41 custom tags.

.PARAMETER IdleInstanceAutoterminationMinutes
The number of minutes that idle instances in excess of the min_idle_instances are maintained by the pool before being terminated. If not specified, excess idle instances are terminated automatically after a default timeout period. If specified, the time must be between 0 and 10000 minutes. If 0 is supplied, excess idle instances are removed as soon as possible.

.PARAMETER PreloadedSparkVersions
A list of Spark image versions the pool installs on each instance. Pool clusters that use one of the preloaded Spark version start faster as they do have to wait for the Spark image to download. You can retrieve a list of available Spark versions by using the Spark Versions API call.

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>
    
Function Add-DatabricksInstancePool {  
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)]
        [string]$BearerToken,    

        [parameter(Mandatory = $false)]
        [string]$Region,
        
        [Alias("instance_pool_name")]
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$InstancePoolName,
        
        [Alias("min_idle_instances")]
        [parameter(Mandatory = $false)]
        [int]$MinIdleInstances,
        
        [Alias("max_capacity")]
        [parameter(Mandatory = $false)]
        [int]$MaxCapacity,
        
        [parameter(Mandatory = $true)]
        [Alias("node_type_id")]
        [string]$NodeType,
        
        [parameter(Mandatory = $false)]
        [Alias("default_tags")]
        [hashtable]$CustomTags,
        
        [parameter(Mandatory = $false)]
        [Alias("idle_instance_autotermination_minutes")]
        [int]$IdleInstanceAutoterminationMinutes,
        
        [parameter(Mandatory = $false)]
        [Alias("preloaded_spark_versions")]
        [string[]]$PreloadedSparkVersions,

        [parameter(Mandatory = $false)]
        [Alias("azure_attributes")]
        [hashtable]$AzureAttributes,

        [parameter(Mandatory = $false)]
        [switch]$UseSpotInstances,

        [Parameter(ValueFromRemainingArguments)]
        $Remaining
    ) 
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters
    
    $Body = @{"instance_pool_name" = $InstancePoolName }
    $ExistingPool = (Get-DatabricksInstancePool -InstancePoolName $InstancePoolName)
    if ($ExistingPool) {
        if ($NodeType -ne $ExistingPool.node_type_id) {
            throw "You cannot change the Node Type of the Pool"
        }
        $Mode = "edit"
        $Body['instance_pool_id'] = $ExistingPool.instance_pool_id
    }
    else {
        $Mode = "create"
    }

    $Body['min_idle_instances'] = $MinIdleInstances
    $Body['node_type_id'] = $NodeType
    if (($CustomTags) -and ($Mode -eq "create")) { $Body['custom_tags'] = $CustomTags }
    if ($IdleInstanceAutoterminationMinutes) { $Body['idle_instance_autotermination_minutes'] = $IdleInstanceAutoterminationMinutes }
    if ($MaxCapacity) { $Body['max_capacity'] = $MaxCapacity }
    if (($PreloadedSparkVersions) -and ($Mode -eq "create")) { $Body['preloaded_spark_versions'] = $PreloadedSparkVersions }

    if ($UseSpotInstances){
        if (!($AzureAttributes)){
            $AzureAttributes = @{}
        }
        $AzureAttributes['availability'] = "SPOT_AZURE"
        $AzureAttributes['spot_bid_max_price'] = -1.0
    }

    if ($AzureAttributes){
        $Body['azure_attributes'] = $AzureAttributes
    }


    $BodyText = $Body | ConvertTo-Json -Depth 10

    $Response = Invoke-RestMethod -Method POST -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/instance-pools/$Mode" -Headers $Headers

    if ($Mode -eq "create") {
        return $Response.instance_pool_id
    }
    else { 
        return $ExistingPool.instance_pool_id 
    }

}