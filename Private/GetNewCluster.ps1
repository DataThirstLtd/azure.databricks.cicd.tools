Function GetNewClusterCluster {  
    param (
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
        [parameter(Mandatory = $false)][ValidateSet(2,3)] [string]$PythonVersion=3,
        [parameter(Mandatory = $false)][string]$ClusterLogPath,
        [parameter(Mandatory = $false)][string]$InstancePoolId,
        [parameter(Mandatory = $false)][hashtable]$AzureAttributes,
        [parameter(Mandatory = $false)][object]$ClusterObject

    ) 
    
    $Body = @{}
    if ($ClusterObject){
        if (($ClusterObject.ssh_public_keys -is [array]) -and ($ClusterObject.ssh_public_keys.count -eq 0)){
            # Issues with Windows PowerShell only - empty array causes bad request
            $ClusterObject.PSObject.properties.remove('ssh_public_keys')
        }
        if (($ClusterObject.init_scripts -is [array]) -and ($ClusterObject.init_scripts.count -eq 0)){
            # Issues with Windows PowerShell only - empty array causes bad request
            $ClusterObject.PSObject.properties.remove('init_scripts')
        }
        $Body = $ClusterObject | ConvertPSObjectToHashtable
    }

    If (($PSBoundParameters.ContainsKey('SparkVersion')) -and ($SparkVersion)) { $Body['spark_version'] = $SparkVersion }
    if ($null -ne $Spark_conf) {$Body['spark_conf'] = $Spark_conf}
    If (($PSBoundParameters.ContainsKey('NodeType')) -and ($NodeType)) { $Body['node_type_id'] = $NodeType }
    If (($PSBoundParameters.ContainsKey('DriverNodeType')) -and ($DriverNodeType)) { $Body['driver_node_type_id'] = $DriverNodeType }
    
    If (($MinNumberOfWorkers -ge 0) -and (-not $ClusterObject)){
        If ($MinNumberOfWorkers -eq $MaxNumberOfWorkers){
            $Body['num_workers'] = $MinNumberOfWorkers
        }
        else {
            $Body['autoscale'] = @{"min_workers"=$MinNumberOfWorkers;"max_workers"=$MaxNumberOfWorkers}
        }
    }

    If (($PSBoundParameters.ContainsKey('CustomTags')) -and ($null -ne $CustomTags)) {
        $Body['custom_tags'] = $CustomTags
    }

    If (($PSBoundParameters.ContainsKey('InitScripts')) -and ($null -ne $InitScripts) -and ($InitScripts.Length -gt 0)) {
        $Body['init_scripts'] = Get-InitScript $InitScripts
    }

    If ($AutoTerminationMinutes -gt 0) {$Body['autotermination_minutes'] = $AutoTerminationMinutes}

    If (!($PSBoundParameters.ContainsKey('SparkEnvVars')) -or ($null -eq $SparkEnvVars)) {
        $SparkEnvVars = @{}
    }

    If ($PythonVersion -eq 3){   
        $SparkEnvVars['PYSPARK_PYTHON'] = "/databricks/python3/bin/python3"
    }

    If ($PSBoundParameters.ContainsKey('SparkEnvVars')) {
        $Body['spark_env_vars'] = $SparkEnvVars
    }

    If ($PSBoundParameters.ContainsKey('ClusterLogPath') -and (!([string]::IsNullOrEmpty($ClusterLogPath)))) {
        $Body['cluster_log_conf'] = @{dbfs=@{destination=$ClusterLogPath}}
    }

    If ($PSBoundParameters.ContainsKey('InstancePoolId') -and (!([string]::IsNullOrEmpty($InstancePoolId)))) {
        $Body['instance_pool_id'] = $InstancePoolId
    }

    if ($null -ne $AzureAttributes) {$Body['azure_attributes'] = $AzureAttributes}

    
    
    Return $Body
}
