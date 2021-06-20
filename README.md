[![Build status](https://dev.azure.com/datathirst/Databricks%20Tools/_apis/build/status/azure.databricks.cicd.tools)](https://dev.azure.com/datathirst/Databricks%20Tools/_build/latest?definitionId=54)
![PSGalleryStatus](https://vsrm.dev.azure.com/datathirst/_apis/public/Release/badge/6982ad16-9bb5-4c62-93c7-e8f22e7e6b1f/1/2)

# azure.databricks.cicd.tools

PowerShell tools for Deploying & Managing Databricks Solutions in Azure. These commandlets help you build continuous delivery pipelines and better source control for your scripts.

## Overview

Supports Windows PowerShell 5 and Powershell Core 6.1+. We generally recommend you use PowerShell Core where possible (it's faster to load modules and downloading large DBFS files may fail in older versions).

See the [Wiki](https://github.com/DataThirstLtd/azure.databricks.cicd.tools/wiki) for command help.

Here is some more detail on use cases for these https://datathirst.net/blog/2019/1/18/powershell-for-azure-databricks

## Install-Module

https://www.powershellgallery.com/packages/azure.databricks.cicd.tools

```powershell
Install-Module -Name azure.databricks.cicd.tools -Scope CurrentUser
```

Followed by:

```powershell
Import-Module -Name azure.databricks.cicd.tools
```

To upgrade from a previous version

```powershell
Update-Module -Name azure.databricks.cicd.tools
```

## Create Service Principal
[Create a new Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal), you will need the following:
* ApplicationId (also known as ClientId)
* Secret Key
* TenantId

Make the Service Principal a Contributor on your Databricks Workspace using the Access Control (IAM) blade in the portal.

## Connect-Databricks
You must first create a connection to Databricks. Currently there are four methods supported:
* Use your already logged in AAD Context from Az PowerShell (requires Az module version 5.1+) - known as **AZCONTEXT**
* Provide the ApplicationId/Secret and the Databricks OrganisationId for your workspace - known as **DIRECT**
  * This is the o=1234567890 number in the URL when you use your workspace
* Provide the ApplicationId/Secret and the SubscriptionID, Resource Group Name & Workspace Name - known as **MANAGEMENT**
* Provide a Bearer token connect as your own user account - known as **BEARER**
  * This is the classic method and not recommended for automated processes
  * It is however still useful for running adhoc commands from your desktop

**NOTE: The first time a service principal connects it must use the MANAGEMENT method as this provisions the service principal in the workspace. Therefore after you can use the DIRECT method.** Without doing this first you will receive a 403 Unauthorized response on all commands. 

### Examples

AZCONTEXT:

You can login with the Az Context of your PowerShell session - assuming you are logged in already use ```Connect-AzAccount```. 

```powershell
Connect-Databricks -UseAzContext -DatabricksOrgId $OrgId -Region $Region
```

You can also use Az PowerShell to get the details using the resource name:
```powershell
$Workspace = (Get-AzDatabricksWorkspace -ResourceGroupName "MyRG" -Name "MyWorkspaceName")
$Region = (($Workspace.Url).split("."))[0,1] -Join "."
Connect-Databricks -UseAzContext -DatabricksOrgId $Workspace.WorkspaceId -Region $Region
```

DIRECT:
```powershell
Connect-Databricks -Region "westeurope" -ApplicationId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3" -Secret "myPrivateSecret" `
            -DatabricksOrgId 1234567 `
            -TenantId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3"
```

MANAGEMENT:
```powershell
Connect-Databricks -Region "westeurope" -ApplicationId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3" -Secret "myPrivateSecret" `
            -ResourceGroupName "MyResourceGroup" `
            -SubscriptionId "9a686882-0e5b-4edb-cd49-cf1f1e7f34d9" `
            -WorkspaceName "workspaceName" `
            -TenantId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3"
```

You can also use this command to connect using the Bearer token so that you do not have to provide them on every command (like you did prior to version 2).

BEARER:
```powershell
Connect-Databricks -BearerToken "dapi1234567890" -Region "westeurope"
```

You can now execute the commands as required without providing further authication in this PowerShell session:
```powershell
Get-DatabricksClusters
```

## Legacy Bearer Token Method
You can continue to execute commands using the bearer token in every request (this will override the session connection (if any)):
```powershell
 Get-DatabricksClusters -BearerToken "dapi1234567890" -Region "westeurope"
```
This is to provide backwards compatibility with version 1 only.  

# Commands

For a full list of commands with help please see the [Wiki](https://github.com/DataThirstLtd/azure.databricks.cicd.tools/wiki).

## Secrets

- Set-DatabricksSecret
- Add-DatabricksSecretScope

Deploys a Secret value to Databricks, this can be a key to a storage account or a password etc. The secret must be created within a scope which will be created for you if it does not exist.

### Key Vault backed secret scopes

Please note that the Databricks REST API currently only supports adding of Key Vault backed scopes using AAD User credentials (NOT Service Principals). Please use the AzContext connect method as an AAD User.

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

-ExportPath: The folder inside Databricks you would like to clone. Eg /Shared/MyETL. Must start /<br>
-LocalOutputPath: The local folder to clone the files to. Ideally inside a repo. Can be qualified or relative.<br>

### Import-DatabricksFolder

Deploy a folder of scripts from a local folder (Git repo) to a specific folder in your Databricks workspace.

**Parameters**

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

## Missing Commands/Bugs

This command can be used for calling the API directly just lookup the syntax (https://docs.databricks.com/dev-tools/api/latest/index.html)

- Invoke-DatabricksAPI

## Examples

See the [Wiki](https://github.com/DataThirstLtd/azure.databricks.cicd.tools/wiki) for help on the commands.
You can also see more examples in the Tests folder.

# Misc

## VSTS/Azure DevOps 

Deployment tasks exist here: https://marketplace.visualstudio.com/items?itemName=DataThirstLtd.databricksDeployScriptsTasks

Note that not all commandlets are available as tasks. Instead you may want to import the module and create PowerShell scripts that use these.

## Contribute
Contributions are welcomed! Please create a pull request with changes/additions.

## Requests
For any requests on new features please check the [Databricks REST API documentation](https://docs.azuredatabricks.net/api/latest/index.html) to see if it is supported first.




