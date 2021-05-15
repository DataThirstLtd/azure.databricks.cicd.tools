

Function Add-DatabricksClusterPolicy {
    <#

.SYNOPSIS
    Create a cluster policy in a Databricks instance.

.DESCRIPTION
    Create a cluster policy in a Databricks instance.

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER policy
    Parameters from parameters file 
    This parameter expect a struction as:
 
         $policy = @{
            name       = "myPolicy"
            definition = '{"spark_version":{"type":"fixed","value":"next-major-version-scala2.12","hidden":true}}'
        }

    .OUTPUTS
    The policy ID

#>

    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AAD')]
        [string]$Region,

        [parameter(Mandatory = $true)]$policy
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    $Body = $policy | ConvertTo-Json

    $policy = Invoke-RestMethod -Method POST -Uri "$global:DatabricksURI/api/2.0/policies/clusters/create" -Body $Body -Headers $Headers

    return $policy.policy_id
}