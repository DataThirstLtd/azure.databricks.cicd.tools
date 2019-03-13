Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psm1" -Force


Describe "Remove Dummy Key"{
    
    It "Simple Execution First" {
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

        $res = Remove-DummyKey($test) 
        $b = $res | ConvertFrom-Json
        $b | Should -Not -BeNullOrEmpty
    }

    It "New Cluster Example" {
      $Test = @'
      {
        "spark_version": "4.0.x-scala2.11",
        "init_scripts": [
          {
            "dbfs": {
              "destination": "dbfs:/script/script1"
            }
          },
          {
            "dbfs": {
              "destination": "dbfs:/script/script2"
            }
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
          "spark.streaming.ui.retainedBatches": 5,
          "spark.speculation": true
        },
        "spark_env_vars": [
          {
            "key": "DummyKey",
            "value": 1
          },
          {
            "key": "SPARK_WORKER_MEMORY",
            "value": "29000m"
          }
        ],
        "node_type_id": "Standard_D3_v2",
        "autotermination_minutes": 15
      }
'@

        $res = Remove-DummyKey($test) 
        $b = $res | ConvertFrom-Json
        $b | Should -Not -BeNullOrEmpty
    }



    It "Escaped Version Last String" {
      $mystr = @'
{
    "new_settings": {
      "existing_cluster_id": "0307-093126-gaps139",
      "spark_python_task": {
        "parameters": [
          "0",
          "{\"DummyKey\":\"1\"}"
        ],
        "python_file": "dbfs:/DatabricksConnectDemo/Code/jobs.py"
      },
      "name": "amazon"
    },
    "job_id": 281
  }
'@

      $res = Remove-DummyKey $mystr
      $b = $res | ConvertFrom-Json
      $b | Should -Not -BeNullOrEmpty
  }

  It "Escaped Version First String" {
    $mystr = @'
{
  "new_settings": {
    "existing_cluster_id": "0307-093126-gaps139",
    "spark_python_task": {
      "parameters": [
        "{\"DummyKey\":\"1\"}",
        "0"
      ],
      "python_file": "dbfs:/DatabricksConnectDemo/Code/jobs.py"
    },
    "name": "amazon"
  },
  "job_id": 281
}
'@

    $res = Remove-DummyKey $mystr
    $b = $res | ConvertFrom-Json
    $b | Should -Not -BeNullOrEmpty
  }

  It "Escaped Version Middle String" {
    $mystr = @'
{
  "new_settings": {
    "existing_cluster_id": "0307-093126-gaps139",
    "spark_python_task": {
      "parameters": [
        "0",
        "{\"DummyKey\":\"1\"}",
        "ABC"
      ],
      "python_file": "dbfs:/DatabricksConnectDemo/Code/jobs.py"
    },
    "name": "amazon"
  },
  "job_id": 281
}
'@

    $res = Remove-DummyKey $mystr
    $b = $res | ConvertFrom-Json
    $b | Should -Not -BeNullOrEmpty
  }

  It "Escaped Version Last Int" {
    $mystr = @'
{
  "new_settings": {
    "existing_cluster_id": "0307-093126-gaps139",
    "spark_python_task": {
      "parameters": [
        0,
        "{\"DummyKey\":\"1\"}"
      ],
      "python_file": "dbfs:/DatabricksConnectDemo/Code/jobs.py"
    },
    "name": "amazon"
  },
  "job_id": 281
}
'@

    $res = Remove-DummyKey $mystr
    $b = $res | ConvertFrom-Json
    $b | Should -Not -BeNullOrEmpty
}

It "Escaped Version First Int" {
  $mystr = @'
{
"new_settings": {
  "existing_cluster_id": "0307-093126-gaps139",
  "spark_python_task": {
    "parameters": [
      "{\"DummyKey\":\"1\"}",
      0
    ],
    "python_file": "dbfs:/DatabricksConnectDemo/Code/jobs.py"
  },
  "name": "amazon"
},
"job_id": 281
}
'@

  $res = Remove-DummyKey $mystr
  $b = $res | ConvertFrom-Json
  $b | Should -Not -BeNullOrEmpty
}

It "Escaped Version Middle Int" {
  $mystr = @'
{
"new_settings": {
  "existing_cluster_id": "0307-093126-gaps139",
  "spark_python_task": {
    "parameters": [
      2,
      "{\"DummyKey\":\"1\"}",
      1
    ],
    "python_file": "dbfs:/DatabricksConnectDemo/Code/jobs.py"
  },
  "name": "amazon"
},
"job_id": 281
}
'@

  $res = Remove-DummyKey $mystr
  $b = $res | ConvertFrom-Json
  $b | Should -Not -BeNullOrEmpty
}



}



