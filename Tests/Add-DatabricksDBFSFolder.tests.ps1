
Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"
$global:Expires = $null
$global:DatabricksOrgId = $null
$global:RefeshToken = $null


Describe "Add-DatabricksDBFSFolder" {
    It "Add-DatabricksDBFSFolder" {
        Add-DatabricksDBFSFolder -Region $Region -BearerToken $BearerToken -FolderPath "/test1/test2/test3"
    }
}

