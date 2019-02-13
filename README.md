[![Build status](https://datathirst.visualstudio.com/DataThirst/_apis/build/status/azure.databricks.cicd.tools)](https://datathirst.visualstudio.com/DataThirst/_build/latest?definitionId=13)
![PSGalleryStatus](https://datathirst.vsrm.visualstudio.com/_apis/public/Release/badge/cceb0041-0508-4178-abee-9b0c30c127e8/1/1)

# azure.databricks.cicd.tools

PowerShell Tools for Deploying Databricks Solutions in Azure. These commandlets help you build continuous delivery pipelines and better source control for your scripts.

## Overview

The CI/CD story in Databricks is complicated. It is designed very much for collaborative working inside the workspace. This probably works well for people doing data science and adhoc queries. But for Data Engineers who what to have build and deployment processes this is usually not good enough.

These tools are designed to help.

These tools should allow you to develop using your preferred methods of Notebooks - in the Databricks Workspace, or via Python or Scala/Java developed in your local IDE. 

You can also use these tools to promote code between environments as part of your build and deploy pipelines.

The tools are now being extended to include more management functions, such as creating, starting & stopping your clusters.

Supports Windows PowerShell 5 and Powershell Core 6.1+

See the [Wiki](https://github.com/DataThirstLtd/azure.databricks.cicd.tools/wiki) for command help.

Here is some more detail on use cases for these https://datathirst.net/blog/2019/1/18/powershell-for-azure-databricks

## Install-Module

https://www.powershellgallery.com/packages/azure.databricks.cicd.tools

```powershell
Install-Module -Name azure.databricks.cicd.tools
```

or

```powershell
Save-Module -Name azure.databricks.cicd.tools -Path \psmodules
```

Followed by:

```powershell
Import-Module -Name azure.databricks.cicd.tools
```

To upgrade from a previous version

```powershell
Update-Module -Name azure.databricks.cicd.tools
```

## Secrets

### Set-DatabricksSecret

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

## DBFS

- Add-DatabricksDBFSFile - Upload a file or folder to DBFS
- Remove-DatabricksDBFSItem - Delete a file or folder
- Get-DatabricksDBFSFolder - List folder contents

The Add-DatabricksDBFSFile can be used as part of a CI/CD pipeline to upload your source code to DBFS, or dependant libraries. You can also use it to deploy initialisation scripts for your clusters.

## Notebooks

### Export-DatabricksFolder

Pull down a folder of scripts from your Databricks workspace so that you can commit the files to your Git repo. It is recommended that you set the OutputPath to be inside your Git repo.

**Parameters**

-BearerToken: Your API token (see Bearer tokens below)<br>
-Region: The Azure Region that hosts your workspace - get this from the start of the URL for your workspace<br>
-ExportPath: The folder inside Databricks you would like to clone. Eg /Shared/MyETL. Must start /<br>
-LocalOutputPath: The local folder to clone the files to. Ideally inside a repo. Can be qualified or relative.<br>

### Import-DatabricksFolder

Deploy a folder of scripts from a local folder (Git repo) to a specific folder in your Databricks workspace.

**Parameters**

-BearerToken: Your API token (see Bearer tokens below)<br>
-Region: The Azure Region that hosts your workspace - get this from the start of the URL for your workspace<br>
-LocalPath: The local folder containing the scripts to deploy. Subfolders will also be deployed.<br>
-DatabricksPath: The folder inside Databricks you would like to deploy into. Eg /Shared/MyETL. Must start /<br>

## Jobs

- Add-DatabricksNotebookJob - Schedule a job based on a Notebook.
- Add-DatabricksPythonJob - Schedule a job based on a Python script (stored in DBFS).
- Add-DatabricksJarJob - Schedule a job based on a Jar (stored in DBFS).
- Add-DatabricksSparkSubmitJob - Schedule a job based on a spark-submit command.
- Remove-DatabricksJob


## Libraries

- Add-DatabricksLibrary
- Get-DatabricksLibraries

## Examples

See the [Wiki](https://github.com/DataThirstLtd/azure.databricks.cicd.tools/wiki) for help on the commands.
You can also see more examples in the tests folder.

## Bearer Tokens

All of the API calls require a Bearer token to authenticate you. To create a token login to your workspace and click on the Person icon in the top right corner. From here go into "User Settings" and click on "Generate New Token". Copy the token into your scripts.

## VSTS/Azure DevOps 

Deployment tasks exist here: https://marketplace.visualstudio.com/items?itemName=DataThirstLtd.databricksDeployScriptsTasks

Note that not all commandlets are available as tasks. Instead you may want to import the module and create PowerShell scripts that use these.

## Contribute
Contributions are welcomed! Please create a pull request with changes/additions.




