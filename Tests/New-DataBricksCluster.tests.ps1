Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

$ClusterName="TestCluster4"
$SparkVersion="4.0.x-scala2.11"
$NodeType="Standard_D3_v2"
$MinNumberOfWorkers=1
$MaxNumberOfWorkers=1
$Spark_conf = @{"spark.speculation"= $true; "spark.streaming.ui.retainedBatches"= 5}
$CustomTags = @{CreatedBy="SimonDM"} #;NumOfNodes=2;CanDelete=$true
$InitScripts = "dbfs:/script/script1" ,"dbfs:/script/script2"
$SparkEnvVars = @{SPARK_WORKER_MEMORY="29000m"} #;SPARK_LOCAL_DIRS="/local_disk0"
$AutoTerminationMinutes = 15
$PythonVersion = 2

Describe "New-DatabricksCluster" {
    It "Create basic cluster"{
        $ClusterId = New-DatabricksCluster  -BearerToken $BearerToken -Region $Region -ClusterName $ClusterName -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -Spark_conf $Spark_conf -CustomTags $CustomTags -AutoTerminationMinutes $AutoTerminationMinutes `
            -Verbose -SparkEnvVars $SparkEnvVars -PythonVersion $PythonVersion -InitScripts $InitScripts    # -UniqueNames -Update

        $ClusterId.cluster_id.Length | Should -BeGreaterThan 1
    }

    AfterAll {
        Start-Sleep -Seconds 5
        Remove-DatabricksCluster -BearerToken $BearerToken -Region $Region -ClusterName $ClusterName
    }
}
