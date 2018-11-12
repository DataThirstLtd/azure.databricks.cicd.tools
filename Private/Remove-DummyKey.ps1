function Remove-DummyKey ([string]$s) {
    while ($s.IndexOf("DummyKey",0) -gt 0) {
        $s = Remove-DummyKeyHelper($s)
    }
    return $s
}

function Remove-DummyKeyHelper ([string]$s){
    $key = $s.IndexOf("DummyKey",0)
    $start = $s.LastIndexOfAny(",",$key)
    $end = $s.IndexOf("}",$key)
    $res = $s.Remove($start,$end-$start+1)

    return $res
}