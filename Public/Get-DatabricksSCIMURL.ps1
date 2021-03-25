function Get-DatabricksSCIMURL {
    [cmdletbinding()]
    param (
        [string]$Api,
        [string]$id,
        [hashtable]$filters
    )

    return Get-SCIMURL -Api $Api -id $id -filters $filters
}