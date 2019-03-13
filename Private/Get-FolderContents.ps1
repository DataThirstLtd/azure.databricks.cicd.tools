function Get-FolderContents ($Path){
    Try
    {
        $Headers = GetHeaders $null
        $uri = "$global:DatabricksURI/api/2.0/workspace/list?path=$Path"
        Write-verbose "Requesting URI $uri"
        $Response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers 
    }
    Catch
    {
        $ResError = $_.ErrorDetails.Message
        Write-Error $ResError
    }
	return $Response 
}