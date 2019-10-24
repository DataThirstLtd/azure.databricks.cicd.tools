<#
.SYNOPSIS
Delete an instance pool from Databricks with given Id

.DESCRIPTION
Delete an instance pool from Databricks with given Id

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER InstancePoolId
Id of the pool to delete

.EXAMPLE
PS C:\> Remove-DatabricksInstancePool -BearerToken $BearerToken -Region $Region -JobId 10

.NOTES
Author: Simon D'Morias / Data Thirst Ltd
#>  

Function Remove-DatabricksInstancePool
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false)][string]$BearerToken, 
        [parameter(Mandatory = $false)][string]$Region,
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("instance_pool_id")] [string]$InstancePoolId
    ) 

    if ("" -eq $InstancePoolId){return}

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters 
    
    $Body = @{}
    $Body['instance_pool_id'] = $InstancePoolId

    $BodyText = $Body | ConvertTo-Json -Depth 10
    
    $Response = Invoke-RestMethod -Method Post -Body $BodyText -Uri "$global:DatabricksURI/api/2.0/instance-pools/delete" -Headers $Headers

    Return $Response
}
    