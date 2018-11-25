Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psm1" -Force

$Test = @'
{
    "node_type_id": "Standard_D3_v2",
    "autotermination_minutes": 15,
    "spark_version": "4.0.x-scala2.11",
    "spark_env_vars": [
      {
        "key": "SPARK_WORKER_MEMORY",
        "value": "29000m"
      },
      {
        "key": "SPARK_LOCAL_DIRS",
        "value": "/local_disk0"
      } 
    ],
    "custom_tags": [
      {
        "key": "DummyKey",
        "value": 1
      },
      {
        "key": "CreatedBy",
        "value": "SimonDM"
      }
    ],
    "num_workers": 1,
    "cluster_name": "TestCluster4",
    "spark_conf": {
      "spark_streaming_ui_retainedBatches": 5,
      "spark_speculation": true
    },
    "custom_tags2": [
      {
        "key": "CreatedBy",
        "value": "SimonDM"
      },
      {
        "key": "DummyKey",
        "value": 1
      }
    ],
  }
'@

$expected = @'
{
    "node_type_id": "Standard_D3_v2",
    "autotermination_minutes": 15,
    "spark_version": "4.0.x-scala2.11",
    "spark_env_vars": [
      {
        "key": "SPARK_WORKER_MEMORY",
        "value": "29000m"
      },
      {
        "key": "SPARK_LOCAL_DIRS",
        "value": "/local_disk0"
      }
    ],
    "custom_tags": [      {
        "key": "CreatedBy",
        "value": "SimonDM"
      }
    ],
    "num_workers": 1,
    "cluster_name": "TestCluster4",
    "spark_conf": {
      "spark_streaming_ui_retainedBatches": 5,
      "spark_speculation": true
    },
    "custom_tags2": [
      {
        "key": "CreatedBy",
        "value": "SimonDM"
      }
    ],
  }
'@

Describe "GetKeyValues"{
    
    It "Simple Execution" {
        $res = Remove-DummyKey($test) 
        $b = $res | ConvertFrom-Json
        $b | Should -Not -BeNullOrEmpty
    }
}



