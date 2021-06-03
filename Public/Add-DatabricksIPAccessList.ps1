<#

.SYNOPSIS
    Add an IP access list.

.DESCRIPTION
The IP Access List API enables Azure Databricks admins to configure IP allow lists and block lists for a workspace.
If the feature is disabled for a workspace, all access is allowed.
There is support for allow lists (inclusion) and block lists (exclusion).

Be sure to check the doc before using this feature:
https://docs.microsoft.com/en-us/azure/databricks/security/network/ip-access-list

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER ListName
    Label for this list

.PARAMETER ListType
    Either ALLOW (allow list) or BLOCK (a block list, which means exclude even if in allow list).

.PARAMETER ListIPs
    A string array of IP addresses and CIDR ranges, as String values.

    .OUTPUTS
    A structure describing the new Access List IP. Looks like:

    {
    "list_id": "<list-id>",
    "label": "office",
    "ip_addresses": [
        "1.1.1.1",
        "2.2.2.2/21"
    ],
    "address_count": 2,
    "list_type": "ALLOW",
    "created_at": 1578423494457,
    "created_by": 6476783916686816,
    "updated_at": 1578423494457,
    "updated_by": 6476783916686816,
    "enabled": true
  }
#>

Function Add-DatabricksIPAccessList {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true, ParameterSetName = 'Bearer')]
        [string]$BearerToken, 

        [parameter(Mandatory = $false, ParameterSetName = 'Bearer')]
        [parameter(Mandatory = $false, ParameterSetName = 'AAD')]
        [string]$Region,

        [parameter(Mandatory = $true)][string]$ListName,
        [parameter(Mandatory = $true, HelpMessage = "Enter an operation type: ALLOW or BLOCK")][string]
        [ValidateSet("ALLOW", "BLOCK")]
        $ListType,
        [parameter(Mandatory = $true)][string[]]$ListIPs
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Headers = GetHeaders $PSBoundParameters

    $URI = "$global:DatabricksURI/api/2.0/ip-access-lists"

    $Body = @{
        label        = $ListName
        list_type    = $ListType
        ip_addresses = $ListIPs
    }
    $BodyText = $Body | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Method Post -Uri $URI -Headers $Headers -Body $BodyText
    return $response.ip_access_list
}