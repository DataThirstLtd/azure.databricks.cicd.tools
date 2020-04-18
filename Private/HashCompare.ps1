function HashCompare{
    [CmdletBinding()]
    param (
        [hashtable]$Previous,
        [hashtable]$New
    )
    $dif = 0
    foreach ($k in $Previous.GetEnumerator()) {
        if ($New.ContainsKey($k.key)){
            if (($k.Value -is [Hashtable])){
                 if($New[$k.key] -is [Hashtable]){
                    $dif += HashCompare -Previous $k.Value -New $New[$k.key]
                 }
                 else{
                     $dif += 1  # One is hashtable the other isn't so must be different
                 }
            }
            elseif ($New[$k.key] -ne $k.Value){$dif += 1}
        }
        else{
            $dif += 1 # Key is missing in $New
        }
    }
    foreach ($k in $New.GetEnumerator()) {
        if (-not ($Previous.ContainsKey($k.key))){
            $dif += 1
        }
    }
    
    return $dif
}


