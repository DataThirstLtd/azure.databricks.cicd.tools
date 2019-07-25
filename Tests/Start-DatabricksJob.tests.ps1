Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$JobName = "StartJobTest"
$SparkVersion = "5.3.x-scala2.11"
$NodeType = "Standard_D3_v2"
$MinNumberOfWorkers = 1
$MaxNumberOfWorkers = 1
$PythonPath = "dbfs:/pythonjobtest/File1.py"
$PythonParameters = "val1", "val2"


Describe "Start-DatabricksJob" { 
    
    It "Start By Job Id" {
        Start-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId $global:jobid -PythonParameters $PythonParameters
    }

    It "Start By Job Name" {
        Start-DatabricksJob -BearerToken $BearerToken -Region $Region -JobName $JobName
    }

    AfterAll{
        Remove-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId $global:jobid
    }

    BeforeAll{
        $global:jobid = Add-DatabricksPythonJob -BearerToken $BearerToken -Region $Region -JobName $JobName `
            -SparkVersion $SparkVersion -NodeType $NodeType `
            -MinNumberOfWorkers $MinNumberOfWorkers -MaxNumberOfWorkers $MaxNumberOfWorkers `
            -PythonPath $PythonPath -PythonParameters $PythonParameters
    }

}
