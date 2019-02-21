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
Id of the job to delete

.EXAMPLE
PS C:\> Remove-DatabricksJob -BearerToken $BearerToken -Region $Region -JobId 10

.NOTES
Author: Simon D'Morias
#>  

Function Remove-DatabricksGroup
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $true)][string]$GroupName
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    $Body = @{}
    $Body['group_name'] = $GroupName

    $BodyText = $Body | ConvertTo-Json -Depth 10
    
    Try {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "https://$Region.azuredatabricks.net/api/2.0/groups/delete" -Headers @{Authorization = $InternalBearerToken}
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
    