Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psm1" -Force
Describe "GetNewCluster" {
        It "Multi Value Settings"{
                $SparkVersion="4.0.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=1
                $Spark_conf = @{"spark.speculation"=$false; "spark.streaming.ui.retainedBatches"= 5}
                $CustomTags = @{CreatedBy="SimonDM";Tag1="HelloWorld"}
                $InitScripts = "dbfs:/script/script1", "dbfs:/script/script2"
                $SparkEnvVars = @{SPARK_WORKER_MEMORY="29000m";SPARK_LOCAL_DIRS="/local_disk0"}
                $AutoTerminationMinutes = 15
                $PythonVersion = 2

                $res = GetNewClusterCluster `
                        -SparkVersion $SparkVersion `
                        -NodeType $NodeType `
                        -DriverNodeType $DriverNodeType `
                        -MinNumberOfWorkers $MinNumberOfWorkers `
                        -MaxNumberOfWorkers $MaxNumberOfWorkers `
                        -AutoTerminationMinutes $AutoTerminationMinutes `
                        -Spark_conf $Spark_conf `
                        -CustomTags $CustomTags `
                        -InitScripts $InitScripts `
                        -SparkEnvVars $SparkEnvVars `
                        -PythonVersion $PythonVersion 

                $s = $res | ConvertTo-Json -Depth 10
                $res['spark_version'] | Should -be "4.0.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 2
                $res['init_scripts'].Count | Should -be 2
                $res['spark_conf'].Count | Should -be 2 -Because "spark_conf"
                $res['init_scripts'][0].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
        }

        It "Single Value Settings"{
                $SparkVersion="4.0.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=1
                $Spark_conf = @{"spark.speculation"=$false}
                $CustomTags = @{CreatedBy="SimonDM"}
                $InitScripts = "dbfs:/script/script1"
                $SparkEnvVars = @{SPARK_WORKER_MEMORY="29000m"}
                $AutoTerminationMinutes = 15
                $PythonVersion = 2

                $res = GetNewClusterCluster `
                        -SparkVersion $SparkVersion `
                        -NodeType $NodeType `
                        -DriverNodeType $DriverNodeType `
                        -MinNumberOfWorkers $MinNumberOfWorkers `
                        -MaxNumberOfWorkers $MaxNumberOfWorkers `
                        -AutoTerminationMinutes $AutoTerminationMinutes `
                        -Spark_conf $Spark_conf `
                        -CustomTags $CustomTags `
                        -InitScripts $InitScripts `
                        -SparkEnvVars $SparkEnvVars `
                        -PythonVersion $PythonVersion 

                $s = $res | ConvertTo-Json -Depth 10
                $BodyText = Remove-DummyKey $s
                $res['spark_version'] | Should -be "4.0.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 2
                $res['init_scripts'].Count | Should -be 1
                $res['spark_conf'].Count | Should -be 1 -Because "spark_conf"
                $res['init_scripts'].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
                $BodyText.IndexOf("Dummy") | Should -be -1
        }

        It "Up Python Version"{
                $SparkVersion="4.0.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=1
                $Spark_conf = @{"spark.speculation"=$false}
                $CustomTags = @{CreatedBy="SimonDM"}
                $InitScripts = "dbfs:/script/script1"
                $SparkEnvVars = @{SPARK_WORKER_MEMORY="29000m"}
                $AutoTerminationMinutes = 15
                $PythonVersion = 3

                $res = GetNewClusterCluster `
                        -SparkVersion $SparkVersion `
                        -NodeType $NodeType `
                        -DriverNodeType $DriverNodeType `
                        -MinNumberOfWorkers $MinNumberOfWorkers `
                        -MaxNumberOfWorkers $MaxNumberOfWorkers `
                        -AutoTerminationMinutes $AutoTerminationMinutes `
                        -Spark_conf $Spark_conf `
                        -CustomTags $CustomTags `
                        -InitScripts $InitScripts `
                        -SparkEnvVars $SparkEnvVars `
                        -PythonVersion $PythonVersion 

                $s = $res | ConvertTo-Json -Depth 10
                $BodyText = Remove-DummyKey $s
                $res['spark_version'] | Should -be "4.0.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 2
                $res['init_scripts'].Count | Should -be 1
                $res['spark_conf'].Count | Should -be 1 -Because "spark_conf"
                $res['init_scripts'].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
                $BodyText.IndexOf("Dummy") | Should -be -1

        }

        It "Python Version 3 with no other EnvVars"{
                $SparkVersion="4.0.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=1
                $Spark_conf = @{"spark.speculation"=$false}
                $CustomTags = @{CreatedBy="SimonDM"}
                $InitScripts = "dbfs:/script/script1"
                $AutoTerminationMinutes = 15
                $PythonVersion = 3

                $res = GetNewClusterCluster `
                        -SparkVersion $SparkVersion `
                        -NodeType $NodeType `
                        -DriverNodeType $DriverNodeType `
                        -MinNumberOfWorkers $MinNumberOfWorkers `
                        -MaxNumberOfWorkers $MaxNumberOfWorkers `
                        -AutoTerminationMinutes $AutoTerminationMinutes `
                        -Spark_conf $Spark_conf `
                        -CustomTags $CustomTags `
                        -SparkEnvVars $null `
                        -InitScripts $InitScripts `
                        -PythonVersion $PythonVersion 

                $s = $res | ConvertTo-Json -Depth 10
                $BodyText = Remove-DummyKey $s
                $res['spark_version'] | Should -be "4.0.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 2
                $res['init_scripts'].Count | Should -be 1
                $res['spark_conf'].Count | Should -be 1 -Because "spark_conf"
                $res['init_scripts'].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
                $BodyText.IndexOf("Dummy") | Should -be -1

        }

        It "Pass NULL on optional sets"{
                $SparkVersion="4.0.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=1
                $Spark_conf = $null
                $CustomTags = $null
                $InitScripts = $null
                $AutoTerminationMinutes = 15
                $PythonVersion = 2

                $res = GetNewClusterCluster `
                        -SparkVersion $SparkVersion `
                        -NodeType $NodeType `
                        -DriverNodeType $null `
                        -MinNumberOfWorkers $MinNumberOfWorkers `
                        -MaxNumberOfWorkers $MaxNumberOfWorkers `
                        -AutoTerminationMinutes $AutoTerminationMinutes `
                        -Spark_conf $Spark_conf `
                        -CustomTags $CustomTags `
                        -SparkEnvVars $null `
                        -InitScripts $InitScripts `
                        -PythonVersion $PythonVersion 

                $s = $res | ConvertTo-Json -Depth 10
                $BodyText = Remove-DummyKey $s
                $res['spark_version'] | Should -be "4.0.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 0
                $res['custom_tags'].Count | Should -be 0
                $res['init_scripts'].Count | Should -be 0
                $res['spark_conf'].Count | Should -be 0
                $BodyText.IndexOf("Dummy") | Should -be -1

        }


        It "Do not pass optional params"{
                $SparkVersion="4.0.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=2

                $res = GetNewClusterCluster `
                        -SparkVersion $SparkVersion `
                        -NodeType $NodeType `
                        -MinNumberOfWorkers $MinNumberOfWorkers `
                        -MaxNumberOfWorkers $MaxNumberOfWorkers 
                        
                $s = $res | ConvertTo-Json -Depth 10
                $BodyText = Remove-DummyKey $s
                $res['spark_version'] | Should -be "4.0.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 0
                $res['custom_tags'].Count | Should -be 0
                $res['init_scripts'].Count | Should -be 0
                $res['spark_conf'].Count | Should -be 0
                $BodyText.IndexOf("Dummy") | Should -be -1

        }
}

