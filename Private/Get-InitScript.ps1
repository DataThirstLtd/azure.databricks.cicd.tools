

Function Get-InitScript([string[]]$InitScripts){
    $InitBlock = @()
    foreach ($s in $InitScripts) {
        $InitBlock += @{dbfs=@{destination=$s}}
    }
    Return $InitBlock
}
