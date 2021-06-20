<#

.SYNOPSIS
    Connects your current PowerShell session to Azure Databricks.

.DESCRIPTION
    Connects your current PowerShell session to Azure Databricks.
    Supports Service Princial AAD authenication or via Databricks Bearer Token

.PARAMETER UseAzContext
    Uses your credentials from your already logged in Az module session
    Can be either Seervice Princpal or User Credentials
    Requires DatabricksOrgId to also be set use:
        ```$OrgId = (Get-AzDatabricksWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName).WorkspaceId ```

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)
    Using Bearer tokens should be avoided - ideally use AAD Authentication

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope
    Also accepts the URL Prefix in place, for example if your URL is https://adb-293060087280.0.azuredatabricks.net/
        then the prefix would be adb-293060087280.0

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

.PARAMETER oauthLogin
    Change the AAD Login URL for China/Government Deployments

.EXAMPLE 
    C:\PS> Connect-Databricks -UseAzContext -Region "adb-293060087280.0" -DatabricksOrgId "1234567"

    This example of logging in using your current Az Context (See Get-AzContext)

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
    [cmdletbinding(DefaultParameterSetName = 'Bearer')]
    param (
        [parameter(Mandatory = $false, ParameterSetName = 'AzContext')]
        [switch]$UseAzContext,

        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken,

        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $true, ParameterSetName = 'AzContext')]
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithResource')]
        [string]$Region,
        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $false, ParameterSetName = 'AADwithResource')]
        [string]$DatabricksURISuffix = "azuredatabricks.net" ,
        [parameter(Mandatory = $false, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $false, ParameterSetName = 'AADwithResource')]
        [string]$oauthLogin = "login.microsoftonline.com" ,
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithResource')]
        [string]$ApplicationId,
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithResource')]
        [string]$Secret,

        [parameter(Mandatory = $true, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName = 'AzContext')]
        [string]$DatabricksOrgId,

        [parameter(Mandatory = $true, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithResource')]
        [string]$TenantId,
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithResource')]
        [string]$SubscriptionId,
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithResource')]
        [string]$ResourceGroupName,
        [parameter(Mandatory = $true, ParameterSetName = 'AADwithResource')]
        [string]$WorkspaceName,

        [parameter(Mandatory = $false, ParameterSetName = 'AADwithOrgId')]
        [parameter(Mandatory = $false, ParameterSetName = 'AADwithResource')]
        [switch]$Force,
        [switch]$TestConnectDatabricks
    ) 

    Write-Verbose "Globals at start of Connect:" 
    Write-Globals

    if ($Force) {
        Write-Verbose "-Force set - clearing global variables"
        Set-GlobalsNull
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $AzureRegion = $Region.Replace(" ", "")
    $AzureDatabricksURISuffix = $DatabricksURISuffix.Trim(".", " ").Replace(" ", "")
    $AzureOauthLogin = $oauthLogin.Trim("/", " ").Replace(" ", "")
    $URI = "https://$AzureOauthLogin/$tenantId/oauth2/token/"
    if ($PSCmdlet.ParameterSetName -eq "Bearer") {
        Set-GlobalsNull
        # Use Databricks Bearer Token Method
        $global:DatabricksAccessToken = "Bearer $BearerToken"
        # Basically do not expire the token
        $global:DatabricksTokenExpires = (Get-Date).AddDays(90)
        $global:Headers = @{"Authorization" = "$global:DatabricksAccessToken" }
    }
    elseif ($PSCmdlet.ParameterSetName -eq "AzContext") {
        $ADResponseToken = Get-AzAccessToken -ResourceUrl "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
        $global:DatabricksAccessToken = $ADResponseToken.Token
        $global:DatabricksTokenExpires = ($ADResponseToken.ExpiresOn).dateTime
        $global:Headers = @{"Authorization" = "Bearer $DatabricksAccessToken";
            "X-Databricks-Org-Id"           = "$DatabricksOrgId"
        }
        $global:DatabricksOrgId = $DatabricksOrgId
    }
    elseif ($PSCmdlet.ParameterSetName -eq "AADwithOrgId") {
        Get-AADDatabricksToken
        $global:Headers = @{"Authorization" = "Bearer $DatabricksAccessToken";
            "X-Databricks-Org-Id"           = "$DatabricksOrgId"
        }
        $global:DatabricksOrgId = $DatabricksOrgId
    }
    elseif ($PSCmdlet.ParameterSetName -eq "AADwithResource") {
        Get-AADManagementToken
        Get-AADDatabricksToken
        $global:Headers = @{"Authorization"            = "Bearer $global:DatabricksAccessToken";
            "X-Databricks-Azure-SP-Management-Token"   = $global:ManagementAccessToken;
            "X-Databricks-Azure-Workspace-Resource-Id" = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Databricks/workspaces/$WorkspaceName"
        }
    }
    $global:DatabricksURI = "https://$AzureRegion.$AzureDatabricksURISuffix"
    Write-Verbose "Globals at end of Connect:" 
    Write-Globals
    if ($PSBoundParameters.ContainsKey('TestConnectDatabricks')) {
        Write-Verbose "Connecting to Workspace to verify connection details are correct:" 
        if ($PSCmdlet.ParameterSetName -eq "Bearer") {
            Test-ConnectDatabricks -Region $AzureRegion -BearerToken $BearerToken
        }
        else {
            Test-ConnectDatabricks
        }
    }
}
