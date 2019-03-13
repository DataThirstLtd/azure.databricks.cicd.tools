function Remove-DummyKey ([string]$s) {
    while ($s.IndexOf("DummyKey",0) -gt 0) {
        $s = Remove-DummyKeyHelper($s)
    }
    return $s
}

function Remove-DummyKeyHelper ([string]$s){
    $key = $s.IndexOf("DummyKey",0)
    $startComma = $s.LastIndexOfAny(",",$key)
    $startBracket = $s.LastIndexOfAny("[",$key)
    if($startComma -gt $startBracket){
        # Not the first item in array
        $end = $s.IndexOf("}",$key)
        $res = $s.Remove($startComma,$end-$startComma+2)
    }
    else {
        # First in array
        $end = $s.IndexOf("}",$key)
        $res = $s.Remove($startBracket+1,$end-$startBracket+2)
    }

    return $res
}

