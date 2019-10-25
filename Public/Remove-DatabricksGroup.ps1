<#
.SYNOPSIS
Delete a group from Databricks with given group name

.DESCRIPTION
Delete a group from Databricks with given group name

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER GroupName
   Name for the group that will be deleted.

.EXAMPLE
PS C:\> Remove-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId 10

.NOTES
Author: Simon D'Morias
#>  

Function Remove-DatabricksGroup
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true)][string]$GroupName
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    
    $Body = @{}
    $Body['group_name'] = $GroupName

    $BodyText = $Body | ConvertTo-Json -Depth 10
    
    Try {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/groups/delete" -Headers $Headers
    }
    Catch {
        $err = $_.ErrorDetails.Message
        if ($err.Contains('RESOURCE_DOES_NOT_EXIST'))
        {
            Write-Verbose $err
        }
        else
        {
            Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
            Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
            Write-Error $err
        }
    }

    Return 
}
    
