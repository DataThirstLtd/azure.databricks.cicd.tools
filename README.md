# azure.databricks.cicd.tools

PowerShell Tools for Deploying Databricks Solutions in Azure. These commandlets help you build continuous delivery pipelines and better source control for your scripts.

## Overview

The CI/CD story in Databricks is complicated. It is designed very much for collaborative working inside the workspace. This probably works well for people doing data science and adhoc queries. But for Data Engineers who what to have build and deployment processes this is usually not good enough.

These tools are designed to help.

The idea is that you continue to develop in the Workspace, when you are happy with your changes you run the Export commandlets to download the notebooks as "Source" files - either Python, SQL, Scala or R files. You can then commit these to a repo for source control. 

You can then deploy the files to another environment/workspace to promote code between environments. This is performed using the Import commandlets.

This is simpler that the Databricks method of linking an individual file to a git repo as this is clunky and has to be repeated for every notebook. There is also limited support for different Git providers.

The tools are now being extended to include more management functions, such as creating, starting & stopping your clusters.

## VSTS/Azure DevOps 

Deployment tasks exist here: https://marketplace.visualstudio.com/items?itemName=DataThirstLtd.databricksDeployScriptsTasks

Note that not all commandlets are available as tasks. Instead you may want to import the module and create PowerShell scripts that use these.

## Install-Module

https://www.powershellgallery.com/packages/azure.databricks.cicd.tools

Install-Module -Name azure.databricks.cicd.tools

or

Save-Module -Name azure.databricks.cicd.tools -Path <path>

Followed by:

Import-Module -Name azure.databricks.cicd.tools

## Export-DatabricksFolder

Pull down a folder of scripts from your Databricks workspace so that you can commit the files to your Git repo. It is recommended that you set the OutputPath to be inside your Git repo.

### Parameters

-BearerToken: Your API token (see Bearer tokens below)<br>
-Region: The Azure Region that hosts your workspace - get this from the start of the URL for your workspace<br>
-ExportPath: The folder inside Databricks you would like to clone. Eg /Shared/MyETL. Must start /<br>
-LocalOutputPath: The local folder to clone the files to. Ideally inside a repo. Can be qualified or relative.<br>

## Import-DatabricksFolder

Deploy a folder of scripts from a local folder (Git repo) to a specific folder in your Databricks workspace.

### Parameters

-BearerToken: Your API token (see Bearer tokens below)<br>
-Region: The Azure Region that hosts your workspace - get this from the start of the URL for your workspace<br>
-LocalPath: The local folder containing the scripts to deploy. Subfolders will also be deployed.<br>
-DatabricksPath: The folder inside Databricks you would like to deploy into. Eg /Shared/MyETL. Must start /<br>

## Set-DatabricksSecret

Deploys a Secret value to Databricks, this can be a key to a storage account or a password etc. The secret must be created within a scope which will be created for you if it does not exist.

## Cluster Management

The following commands exist:

- Get-DatabricksClusters - Returns a list of all clusters in your workspace
- New-DatabricksCluster - Creates/Updates a cluster
- Start-DatabricksCluster
- Stop-DatabricksCluster
- Update-DatabricksClusterResize - Modify the number of scale workers
- Remove-DatabricksCluster - Deletes your cluster
- Get-DatabricksNodeTypes - returns a list of valid nodes type (such as DS3v2 etc)
- Get-DatabricksSparkVersions - returns a list of valid versions

Please see the scripts of the parameters. Examples are available in the Tests folder.

These have been designed with CI/CD in mind - ie they should all be idempotent.

## Examples

Please see the tests folder for examples and details of how to import this module.

## Bearer Tokens

All of the API calls require a Bearer token to authenticate you. To create a token login to your workspace and click on the Person icon in the top right corner. From here go into "User Settings" and click on "Generate New Token". Copy the token into your scripts.

## Libraries

The ability to import libraries into Databricks is not currently included. This is due to limitations in the REST API from Databricks where libraries must be attached to a specific cluster by id and do not show in the Databricks UI. This should be addressed in the future.

## Build, Compile & Test

Unfortunately there is currently no way to compile the source scripts exported from Databricks to validate that they work. Therefore automated build > deploy > test is not possible. If Databricks ever make it possible to remote attach notebooks to a cluster this maybe possible. In the meantime we are working on a solution for basic tests and returning results for publishing in your favorite build tool. However this is someway off (as at July 2018). Please star this repo to get updates on this.



