function Get-DatabricksSCIMURL {
    [cmdletbinding()]
    param (
        [string]$Api,
        [Parameter(Mandatory=$false)][string]$id,
        [Parameter(Mandatory=$false)][hashtable]$filters = @{}
    )

    return Get-SCIMURL -Api $Api -id $id -filters $filters
}