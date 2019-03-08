
$dict = @{}
[object[]]$myarray = "1", 1, 2

$myarray.GetType()

$dict['params'] = $myarray

$dict | ConvertTo-Json