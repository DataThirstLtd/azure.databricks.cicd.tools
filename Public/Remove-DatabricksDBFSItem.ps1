Function Remove-DatabricksDBFSItem
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $false)][string]$Path
    ) 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    $Body = @{}
    $Body['path'] = $Path
    $Body['recursive'] = 'true'

    $BodyText = $Body | ConvertTo-Json -Depth 10
    
    Try {
        Invoke-RestMethod -Method Post -Body $BodyText -Uri "https://$Region.azuredatabricks.net/api/2.0/dbfs/delete" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    Return 
}
    