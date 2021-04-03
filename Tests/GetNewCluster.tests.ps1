Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psm1" -Force
Describe "GetNewCluster" {
        It "Multi Value Settings"{
                $SparkVersion="5.5.x-scala2.11"
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

                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 2
                $res['init_scripts'].Count | Should -be 2
                $res['spark_conf'].Count | Should -be 2 -Because "spark_conf"
                $res['init_scripts'][0].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
        }

        It "Single Value Settings"{
                $SparkVersion="5.5.x-scala2.11"
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

                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 1
                $res['custom_tags'].Count | Should -be 1
                $res['init_scripts'].Count | Should -be 1
                $res['spark_conf'].Count | Should -be 1 -Because "spark_conf"
                $res['init_scripts'].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
        }

        It "Up Python Version"{
                $SparkVersion="5.5.x-scala2.11"
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

                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 1
                $res['init_scripts'].Count | Should -be 1
                $res['spark_conf'].Count | Should -be 1 -Because "spark_conf"
                $res['init_scripts'].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
        }

        It "Python Version 3 with no other EnvVars"{
                $SparkVersion="5.5.x-scala2.11"
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

                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 1
                $res['custom_tags'].Count | Should -be 1
                $res['init_scripts'].Count | Should -be 1
                $res['spark_conf'].Count | Should -be 1 -Because "spark_conf"
                $res['init_scripts'].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"

        }

        It "Pass NULL on optional sets"{
                $SparkVersion="5.5.x-scala2.11"
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
                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 0
                $res['custom_tags'].Count | Should -be 0
                $res['init_scripts'].Count | Should -be 0
                $res['spark_conf'].Count | Should -be 0
                $BodyText.IndexOf("Dummy") | Should -be -1

        }

        It "Do not pass optional params"{
                $SparkVersion="5.5.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=2

                $res = GetNewClusterCluster `
                        -SparkVersion $SparkVersion `
                        -NodeType $NodeType `
                        -MinNumberOfWorkers $MinNumberOfWorkers `
                        -MaxNumberOfWorkers $MaxNumberOfWorkers 
                        
                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 0
                $res['custom_tags'].Count | Should -be 0
                $res['init_scripts'].Count | Should -be 0
                $res['spark_conf'].Count | Should -be 0

        }

        It "Multi Value Settings with AzureAttributes"{
                $SparkVersion="5.5.x-scala2.11"
                $NodeType="Standard_D3_v2"
                $MinNumberOfWorkers=1
                $MaxNumberOfWorkers=1
                $Spark_conf = @{"spark.speculation"=$false; "spark.streaming.ui.retainedBatches"= 5}
                $CustomTags = @{CreatedBy="SimonDM";Tag1="HelloWorld"}
                $InitScripts = "dbfs:/script/script1", "dbfs:/script/script2"
                $SparkEnvVars = @{SPARK_WORKER_MEMORY="29000m";SPARK_LOCAL_DIRS="/local_disk0"}
                $AutoTerminationMinutes = 15
                $PythonVersion = 2
                $AzureAttributes = @{first_on_demand=1; availability="SPOT_WITH_FALLBACK_AZURE"; spot_bid_max_price=-1}

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
                        -PythonVersion $PythonVersion `
                        -AzureAttributes $AzureAttributes

                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_D3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 2
                $res['init_scripts'].Count | Should -be 2
                $res['spark_conf'].Count | Should -be 2 -Because "spark_conf"
                $res['init_scripts'][0].dbfs.destination | Should -be "dbfs:/script/script1" -Because "Init Scripts"
                $res['azure_attributes'].Count | Should -be 3 -Because "azure_attributes"
                $res['azure_attributes'].availability | Should -be "SPOT_WITH_FALLBACK_AZURE" -Because "azure_attributes"
        }

        It "Pass as json"{
                $json = '{
                        "num_workers": 1,
                        "cluster_name": "CICD",
                        "spark_version": "6.4.x-scala2.11",
                        "spark_conf": {
                            "spark.databricks.service.server.enabled": "true",
                            "spark.databricks.service.port": "8787",
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
                            "LIQUIXCONFIG": "/dbfs/liquix/config.json"
                        },
                        "autotermination_minutes": 30,
                        "enable_elastic_disk": true,
                        "cluster_source": "UI",
                        "init_scripts": [],
                        "cluster_id": "0920-081811-lamps471"
                    }' | ConvertFrom-Json

                $res = GetNewClusterCluster `
                        -ClusterObject $json
                
                $res['spark_version'] | Should -be "6.4.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_DS3_v2"
                $res['spark_env_vars'].Count | Should -be 1
                $res['custom_tags'].Count | Should -be 0
                $res['init_scripts'].Count | Should -be 0
                $res['spark_conf'].Count | Should -be 3
        }

        It "Pass as json with AzureAttributes"{
                $json = '{
                        "num_workers": 1,
                        "cluster_name": "CICD",
                        "spark_version": "6.4.x-scala2.11",
                        "spark_conf": {
                            "spark.databricks.service.server.enabled": "true",
                            "spark.databricks.service.port": "8787",
                            "spark.databricks.delta.preview.enabled": "true"
                        },
                        "azure_attributes": {
                            "first_on_demand": 1,
                            "availability": "SPOT_WITH_FALLBACK_AZURE",
                            "spot_bid_max_price": -1
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
                            "LIQUIXCONFIG": "/dbfs/liquix/config.json"
                        },
                        "autotermination_minutes": 30,
                        "enable_elastic_disk": true,
                        "cluster_source": "UI",
                        "init_scripts": [],
                        "cluster_id": "0920-081811-lamps471"
                    }' | ConvertFrom-Json

                $res = GetNewClusterCluster `
                        -ClusterObject $json
                
                $res['spark_version'] | Should -be "6.4.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_DS3_v2"
                $res['spark_env_vars'].Count | Should -be 1
                $res['custom_tags'].Count | Should -be 0
                $res['init_scripts'].Count | Should -be 0
                $res['spark_conf'].Count | Should -be 3
                $res['azure_attributes'].Count | Should -be 3 -Because "azure_attributes"
                $res['azure_attributes'].availability | Should -be "SPOT_WITH_FALLBACK_AZURE" -Because "azure_attributes"
        }

        It "Override as json values"{
                $json = '{
                        "num_workers": 1,
                        "cluster_name": "CICD",
                        "spark_version": "6.4.x-scala2.11",
                        "spark_conf": {
                            "spark.databricks.service.server.enabled": "true",
                            "spark.databricks.service.port": "8787",
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
                            "LIQUIXCONFIG": "/dbfs/liquix/config.json"
                        },
                        "autotermination_minutes": 30,
                        "enable_elastic_disk": true,
                        "cluster_source": "UI",
                        "init_scripts": [],
                        "cluster_id": "0920-081811-lamps471"
                    }' | ConvertFrom-Json

                $res = GetNewClusterCluster `
                        -ClusterObject $json `
                        -SparkVersion "5.5.x-scala2.11" `
                        -CustomTags @{CreatedBy="SimonDM"} `
                        -SparkEnvVars @{SPARK_WORKER_MEMORY="29000m"}

                $res['spark_version'] | Should -be "5.5.x-scala2.11"
                $res['Node_type_id'] | Should -be "Standard_DS3_v2"
                $res['spark_env_vars'].Count | Should -be 2
                $res['custom_tags'].Count | Should -be 1
                $res['init_scripts'].Count | Should -be 0
                $res['spark_conf'].Count | Should -be 3
        }

       
}

