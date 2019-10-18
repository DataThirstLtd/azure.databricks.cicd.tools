<#

.SYNOPSIS
    Connects your current PowerShell session to Azure Databricks.

.DESCRIPTION
    Connects your current PowerShell session to Azure Databricks.
    Supports Service Princial AAD authenication or via Databricks Bearer Token

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ApplicationId
    Azure Active Directory Service Principal Client ID (also known as Application ID)
    
.PARAMETER Secret
    Secret for given Client ID

.PARAMETER DatabricksOrgId
    Databricks OrganisationID this is found in the URL of your Worksapce as the o parameters (example o=123456789). Note the first time a service principal connects it must use the MANAGEMENT method (ie provide the Resource GRoup Name and Workspace Name - as this provisions the user)

.PARAMETER TenantId
    Tenant Id (Directory ID) for the AAD owning the ApplicationId

.PARAMETER SubscriptionId
    Subscription ID for the Workspace

.PARAMETER ResourceGroupName
    Resource Group Name for the Workspace

.PARAMETER WorkspaceName
    Workspace Name

.PARAMETER Force
    Removes any cached credentials and reconnects

.EXAMPLE 
    C:\PS> Connect-Databricks -Region "westeurope" -ApplicationId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3" -Secret "myPrivateSecret" -DatabricksOrgId 1234567 -TenantId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3"

    This example of a DIRECT connection (using the Databricks organisation Id)

.EXAMPLE 
    C:\PS> Connect-Databricks -Region "westeurope" -ApplicationId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3" -Secret "myPrivateSecret" -ResourceGroupName "MyResourceGroup" -SubscriptionId "9a686882-0e5b-4edb-cd49-cf1f1e7f34d9" -WorkspaceName "workspaceName" -TenantId "8a686772-0e5b-4cdb-ad19-bf1d1e7f89f3"

    This example of a MANAGMENT connection (using the Azure resource identifiers to connect)

.EXAMPLE 
    C:\PS> Connect-Databricks -BearerToken "dapi1234567890" -Region "westeurope"

    This example of a BEARER connection (using the Databricks Bearer token from the Web UI to login as a person)

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

Function Connect-Databricks {  
    [cmdletbinding(DefaultParameterSetName='Bearer')]
    param (
        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [string]$BearerToken,

        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [parameter(Mandatory = $true, ParameterSetName='AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName='AADwithResource')]
        [string]$Region,

        [parameter(Mandatory = $true, ParameterSetName='AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName='AADwithResource')]
        [string]$ApplicationId,
        [parameter(Mandatory = $true, ParameterSetName='AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName='AADwithResource')]
        [string]$Secret,

        [parameter(Mandatory = $true, ParameterSetName='AADwithOrgId')]
        [string]$DatabricksOrgId,

        [parameter(Mandatory = $true, ParameterSetName='AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName='AADwithResource')]
        [string]$TenantId,
        [parameter(Mandatory = $true, ParameterSetName='AADwithResource')]
        [string]$SubscriptionId,
        [parameter(Mandatory = $true, ParameterSetName='AADwithResource')]
        [string]$ResourceGroupName,
        [parameter(Mandatory = $true, ParameterSetName='AADwithResource')]
        [string]$WorkspaceName,

        [parameter(Mandatory = $false, ParameterSetName='AADwithOrgId')]
        [parameter(Mandatory = $false, ParameterSetName='AADwithResource')]
        [switch]$Force
    ) 

    Write-Verbose "Globals at start of Connect:" 
    Write-Globals

    if ($Force){
        Write-Verbose "-Force set - clearing global variables"
        Set-GlobalsNull
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $AzureRegion = $Region.Replace(" ","")
    $URI = "https://login.microsoftonline.com/$tenantId/oauth2/token/"

    if ($PSCmdlet.ParameterSetName -eq "Bearer"){
        Set-GlobalsNull
        # Use Databricks Bearer Token Method
        $global:DatabricksAccessToken = "Bearer $BearerToken"
        # Basically do not expire the token
        $global:DatabricksTokenExpires = (Get-Date).AddDays(90)
        $global:Headers = @{"Authorization"="$global:DatabricksAccessToken"}
    }
    elseif($PSCmdlet.ParameterSetName -eq "AADwithOrgId"){
        Get-AADDatabricksToken
        $global:Headers = @{"Authorization"="Bearer $DatabricksAccessToken";
            "X-Databricks-Org-Id"="$DatabricksOrgId"
        }
        $global:DatabricksOrgId = $DatabricksOrgId
    }
    elseif($PSCmdlet.ParameterSetName -eq "AADwithResource"){
        Get-AADManagementToken
        Get-AADDatabricksToken
        $global:Headers = @{"Authorization"="Bearer $global:DatabricksAccessToken";
            "X-Databricks-Azure-SP-Management-Token"=$global:ManagementAccessToken;
            "X-Databricks-Azure-Workspace-Resource-Id"="/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Databricks/workspaces/$WorkspaceName"
        }
    }

    $global:DatabricksURI = "https://$AzureRegion.azuredatabricks.net" 

    Write-Verbose "Globals at end of Connect:" 
    Write-Globals
}
