<#
.SYNOPSIS
Pulls the contents of a Databricks folder (and subfolders) locally so that they can be committed to a repo

.DESCRIPTION
Pulls the contents of a Databricks folder (and subfolders) locally so that they can be committed to a repo

.PARAMETER BearerToken
Your Databricks Bearer token to authenticate to your workspace (see User Settings in Datatbricks WebUI)

.PARAMETER Region
Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER InstancePoolId
Optional. Returns just a single pool.

.PARAMETER InstancePoolName
Optional. Returns just a single pool.

.EXAMPLE
PS C:\> Get-DatabricksInstancePool -BearerToken $BearerToken -Region $Region

Returns all pools

.NOTES
Author: Simon D'Morias / Data Thirst Ltd

#>

Function Get-DatabricksInstancePool
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName='Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName='Bearer')]
        [parameter(Mandatory = $false, ParameterSetName='AAD')]
        [string]$Region,
        
        [parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$InstancePoolId,
        [parameter(Mandatory = $false)]
        [string]$InstancePoolName
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters


    $Instances = Invoke-RestMethod -Method Get -Uri "$global:DatabricksURI/api/2.0/instance-pools/list" -Headers $Headers
   
    if ($PSBoundParameters.ContainsKey('InstancePoolId')){
        $Result = $Instances.instance_pools | Where-Object {$_.instance_pool_id -eq $InstancePoolId}
        Return $Result
    }
    elseif ($PSBoundParameters.ContainsKey('InstancePoolName')){
        $Result = $Instances.instance_pools | Where-Object {$_.instance_pool_name -eq $InstancePoolName}
        Return $Result
    }
    else {
        Return $Instances.instance_pools
    }
}
    