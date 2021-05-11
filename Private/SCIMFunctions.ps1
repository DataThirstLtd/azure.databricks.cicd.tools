

function Get-SCIMURL {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Api,
        [Parameter(Mandatory=$false)][string]$id,
        [Parameter(Mandatory=$false)][hashtable]$filters = @{}
    )
    
    $Root = '/api/2.0/preview/scim/v2/'

    if ($PSBoundParameters.ContainsKey('id')){
        $uri = $Root + $Api + "/" + $id
    }
    else{
        $uri = $Root + $Api
    }

    if ($PSBoundParameters.ContainsKey('filters')){
        [System.Collections.ArrayList]$filterList = @()
        $filters.GetEnumerator()  | ForEach-Object { $filterList.Add("$($_.Name)=$($_.Value)") } | Out-Null

        $uri = $uri + "?" + ($filterList -join "&")
    }
    return $uri
}


function Add-SCIMSchema {
    [cmdletbinding()]
    param (
        [string[]]$schemas
    )
    $res = @{"schemas"=$schemas} 
    return $res
}


function Add-SCIMValueArray {
    [cmdletbinding()]
    param (
        [string]$Parent,
        [string[]]$Values
    )
    
    $ResArray = @()
    ForEach ($e in $Values) {
        $ResArray += @{"value"=$e}
    }

    return @{"$Parent"=$ResArray} 
}