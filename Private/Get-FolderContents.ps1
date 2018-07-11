function Get-FolderContents ($Path, $Region, $InternalBearerToken){
    Try
    {
        $uri = "https://$Region.azuredatabricks.net/api/2.0/workspace/list?path=$Path"
        Write-verbose "Requesting URI $uri"
        $Response = Invoke-RestMethod -Method Get -Uri $uri -Headers @{Authorization = $InternalBearerToken} 
    }
    Catch
    {
        $ResError = $_.ErrorDetails.Message
        Write-Error $ResError
    }
	return $Response 
}