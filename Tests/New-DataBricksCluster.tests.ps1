param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode){
    ("Bearer"){
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal"){
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

$ClusterName="TestCluster5"
$SparkVersion="5.5.x-scala2.11"
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

Describe "New-DatabricksCluster" {
    It "Create basic cluster"{
        $ClusterId = New-DatabricksCluster  -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes -ClusterLogPath $ClusterLogPath `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts    # -UniqueNames -Update 

        $ClusterId.cluster_id.Length | Should -BeGreaterThan 1
    }

    AfterAll {
        Start-Sleep -Seconds 5
        Remove-DatabricksCluster -ClusterName $ClusterName
    }
}
