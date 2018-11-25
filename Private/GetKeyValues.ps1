

function GetKeyValues([hashtable]$pairs){
    $res = @()
    $pairs.GetEnumerator() | ForEach-Object {
        $res += [ordered]@{key=$_.key;value=$_.value}
    }
    return $res
}


