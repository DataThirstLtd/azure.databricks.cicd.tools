param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($Mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

$ClusterName="TestCluster7"
$SparkVersion="7.3.x-scala2.12"
$NodeType="Standard_D3_v2"
$MinNumberOfWorkers=1
$MaxNumberOfWorkers=1
$Spark_conf = @{"spark.speculation"= $true; "spark.streaming.ui.retainedBatches"= 5}
$CustomTags = @{CreatedBy="SimonDM"} #;NumOfNodes=2;CanDelete=$true
$InitScripts = "dbfs:/script/script1" ,"dbfs:/script/script2"
$SparkEnvVars = @{SPARK_WORKER_MEMORY="29000m"} #;SPARK_LOCAL_DIRS="/local_disk0"
$AutoTerminationMinutes = 15
$PythonVersion = 3
$ClusterLogPath = "dbfs:/logs/mycluster"
$AzureAttributes = @{
    first_on_demand = 1
    availability = "SPOT_WITH_FALLBACK_AZURE"
    spot_bid_max_price = -1
}

Describe "New-DatabricksCluster" {
    It "Create basic cluster"{
        $ClusterId = New-DatabricksCluster  -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes -ClusterLogPath $ClusterLogPath `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts

        $ClusterId.Length | Should -BeGreaterThan 1
    }

    AfterAll {
        Start-Sleep -Seconds 5
        Remove-DatabricksCluster -ClusterName $ClusterName
    }
}

Describe "New-DatabricksCluster with AzureAttributes" {
    It "Create basic cluster with AzureAttributes"{
        $ClusterId = New-DatabricksCluster  -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes -ClusterLogPath $ClusterLogPath `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts -AzureAttributes $AzureAttributes

        $ClusterId.Length | Should -BeGreaterThan 1
    }

    AfterAll {
        Start-Sleep -Seconds 5
        Remove-DatabricksCluster -ClusterName $ClusterName
    }
}

Describe "Edit Cluster New-DatabricksCluster" {
    BeforeAll{
        $global:ClusterId = New-DatabricksCluster  -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes -ClusterLogPath $ClusterLogPath `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts
        Start-Sleep -Seconds 3
        Stop-DatabricksCluster -ClusterName $ClusterName
        Start-Sleep -Seconds 3
    }

    It "Update cluster auto term"{
        $ClusterIdEdited = New-DatabricksCluster -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes 55 -ClusterLogPath $ClusterLogPath `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts

        $ClusterIdEdited | Should -Be $global:ClusterId
    }

    AfterAll {
        Start-Sleep -Seconds 3
        Remove-DatabricksCluster -ClusterName $ClusterName
    }
}

Describe "Edit Cluster New-DatabricksCluster with AzureAttributes" {
    BeforeAll{
        $global:ClusterId = New-DatabricksCluster  -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes -ClusterLogPath $ClusterLogPath `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts
        Start-Sleep -Seconds 3
        Stop-DatabricksCluster -ClusterName $ClusterName
        Start-Sleep -Seconds 3
    }

    It "Update cluster with AzureAttributes (Spot Instances)"{
        $ClusterIdEdited = New-DatabricksCluster -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes -ClusterLogPath $ClusterLogPath `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts -AzureAttributes $AzureAttributes

        $EditedClusterConfig = Get-DatabricksClusters -ClusterId $ClusterIdEdited
        $EditedClusterConfig.azure_attributes.availability | Should -Be $AzureAttributes.availability
    }

    AfterAll {
        Start-Sleep -Seconds 3
        Remove-DatabricksCluster -ClusterName $ClusterName
    }
}

Describe "New Cluster - via pipe"{
    It "Basic Pipe" {
        $json = '{
            "num_workers": 1,
            "cluster_name": "UnitTestPipeCluster",
            "spark_version": "7.3.x-scala2.12",
            "spark_conf": {
                "spark.databricks.service.port": "8787",
                "spark.databricks.service.server.enabled": "true",
                "spark.databricks.delta.preview.enabled": "true"
            },
            "node_type_id": "Standard_DS3_v2",
            "driver_node_type_id": "Standard_DS3_v2",
            "ssh_public_keys": [],
            "custom_tags": {},
            "cluster_log_conf": {
                "dbfs": {
                    "destination": "dbfs:/cluster-logs"
                }
            },
            "spark_env_vars": {
                "LIQUIXCONFIG": "/dbfs/liquix/config.json",
                "LIQUIXCONFIG2": "/dbfs/liquix/config.json"
            },
            "autotermination_minutes": 30,
            "enable_elastic_disk": true,
            "cluster_source": "UI",
            "init_scripts": []
        }' | ConvertFrom-Json

        $NewClusterId = ($json | New-DatabricksCluster -Verbose)
        Start-Sleep -Seconds 5
        $Result = Get-DatabricksClusters -ClusterId $NewClusterId -Verbose

        $Result.num_workers | Should -be $json.num_workers
        $Result.autotermination_minutes | Should -be $json.autotermination_minutes
        $Result.driver_node_type_id | Should -be $json.driver_node_type_id

    }

    AfterAll{
        Remove-DatabricksCluster -ClusterName "UnitTestPipeCluster"
    }
    

}