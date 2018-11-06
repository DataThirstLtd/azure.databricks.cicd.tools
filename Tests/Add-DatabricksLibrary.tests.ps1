Import-Module "$PSScriptRoot\..\azure.databricks.cicd.tools.psm1" -Force

$BearerToken = Get-Content "$PSScriptRoot\MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

$ClusterId = (Get-DatabricksClusters -BearerToken $BearerToken -Region $Region).cluster_id[0]

Write-Output $ClusterId

#Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region `
#    -LibraryType "pypi" -LibrarySettings '{ "package": "simplejson"}' `
#    -ClusterId $ClusterId

Add-DatabricksLibrary -BearerToken $BearerToken -Region $Region `
    -LibraryType "jar" -LibrarySettings 'dbfs:/mnt/libraries/library.jar' `
    -ClusterId $ClusterId
    