<#

.SYNOPSIS
    Add permissions to objects

.DESCRIPTION
    Add permissions to objects

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Principal
    The name of the "user","group","service_principal" that will be added to the object.
    
.PARAMETER PrincipalType
  Which type of pricipal do you want to add to the object.
  Valid values for this parameter are: 
  "user_name"​​ || ​"group_name"​ ​|| "service_principal_name"

.PARAMETER PermissionLevel
    See Get-DatabricksPermissionLevels
    For Secret Scopes this value must be READ, WRITE or MANAGE

.PARAMETER DatabricksObjectType
    Job, Cluster, secretScope or Instance-pool

.PARAMETER DatabricksObjectId
    JobId, ClusterId, secretScope or Instance-poolId

.EXAMPLE 
    C:\PS> Set-DatabricksPermission -BearerToken $BearerToken -Region $Region -Principal "MyTestGroup" -PermissionLevel 'CAN_MANAGE' -DatabricksObjectType 'Cluster' -DatabricksObjectId "tubby-1234"

    This adds the permission CAN_MANAGE to a cluster for all users in the MyTestGroup

.NOTES
    Author: Simon D'Morias / Data Thirst Ltd

#>

Function Set-DatabricksPermission
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$false)][string]$BearerToken,
        [parameter(Mandatory=$false)][string]$Region,
        [parameter(Mandatory=$true)][string]$Principal,
        [parameter(Mandatory=$false)][ValidateSet('user_name','group_name','service_principal_name')][string]$PrincipalType = 'user_name',
        [Parameter(Mandatory=$true)][string]$PermissionLevel,
        [Parameter(Mandatory=$true)][ValidateSet('job','cluster','instance-pool', 'secretScope')][string]$DatabricksObjectType,
        [Parameter(Mandatory=$true)][string]$DatabricksObjectId
    )

    $Headers = GetHeaders $PSBoundParameters

    if ($DatabricksObjectType -eq "secretScope"){
        $URI = "$global:DatabricksURI/api/2.0/secrets/acls/put"
        $Body = @{scope=$DatabricksObjectId; principal=$Principal; permission=$PermissionLevel} | ConvertTo-Json -Depth 10
        try{
            Write-Verbose $Body
            $Response = Invoke-RestMethod -Method POST -Body $Body -Uri $URI -Headers $Headers
        }
        catch{
            $err = $_.ErrorDetails.Message
            if ($err.Contains('exists'))
            {
                Write-Verbose $err
            }
            else
            {
                throw $err
            }
        }
        return $Response
    }
    else {
        $BasePath = "$global:DatabricksURI/api/2.0/preview"
        $URI =  "$BasePath/permissions/$DatabricksObjectType" + "s/$DatabricksObjectId"
    
    
        switch ($PrincipalType) 
        { 
            "user_name" {$acl = @(@{"user_name"= $Principal; "permission_level"=$PermissionLevel})} 
            "group_name" {$acl = @(@{"group_name"= $Principal; "permission_level"=$PermissionLevel})} 
            "service_principal_name" {$acl = @(@{"service_principal_name"= $Principal; "permission_level"=$PermissionLevel})} 
        }
        
        $Body = @{"access_control_list"= $acl} | ConvertTo-Json -Depth 10

        Write-Verbose $Body
        $Response = Invoke-RestMethod -Method PATCH -Body $Body -Uri $URI -Headers $Headers
    }
    
    return $Response
}

