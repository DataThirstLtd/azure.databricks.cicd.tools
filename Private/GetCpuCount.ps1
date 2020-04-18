

function GetCpuCount{
    if($PSVersionTable.Platform -eq "Unix"){
        return 4
    }
    else{
        (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors * 2
    }

}
