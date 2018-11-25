
Function GetNewClusterCluster {  
    param (
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
        [parameter(Mandatory = $false)][ValidateSet(2,3)] [string]$PythonVersion=2
    ) 
    
    $Body = @{}
    $Body['spark_version'] = $SparkVersion
    if ($null -ne $Spark_conf) {$Body['spark_conf'] = $Spark_conf}
    $Body['node_type_id'] = $NodeType
    If (($PSBoundParameters.ContainsKey('DriverNodeType')) -and ($DriverNodeType)) { $Body['driver_node_type_id'] = $DriverNodeType }
    If ($MinNumberOfWorkers -eq $MaxNumberOfWorkers){
        $Body['num_workers'] = $MinNumberOfWorkers
    }
    else {
        $Body['autoscale'] = @{"min_workers"=$MinNumberOfWorkers;"max_workers"=$MaxNumberOfWorkers}
    }

    If (($PSBoundParameters.ContainsKey('CustomTags')) -and ($null -ne $CustomTags)) {
        If ($CustomTags.Count -eq 1) {
            $CustomTags.Add('DummyKey', 1)
        }
        $Body['custom_tags'] = GetKeyValues $CustomTags
    }

    If (($PSBoundParameters.ContainsKey('InitScripts')) -and ($null -ne $InitScripts)) {
        $Body['init_scripts'] = Get-InitScript $InitScripts
    }

    If ($PSBoundParameters.ContainsKey('AutoTerminationMinutes')) {$Body['autotermination_minutes'] = $AutoTerminationMinutes}

    If (!($PSBoundParameters.ContainsKey('SparkEnvVars')) -or ($null -eq $SparkEnvVars)) {
        $SparkEnvVars = @{}
    }

    If ($PythonVersion -eq 3){   
        $SparkEnvVars['PYSPARK_PYTHON'] = "/databricks/python3/bin/python3"
    }

    If ($SparkEnvVars.Count -gt 0) {
        If ($SparkEnvVars.Count -eq 1) {
            $SparkEnvVars.Add('DummyKey', 1)
        }
        $Body['spark_env_vars'] = GetKeyValues $SparkEnvVars
    }
    
    Return $Body
}