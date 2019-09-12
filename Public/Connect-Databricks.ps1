
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
        [string]$ClientId,
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
        $global:Headers = @{"Authorization"="Bearer $global:DatabricksAccessToken"}
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
