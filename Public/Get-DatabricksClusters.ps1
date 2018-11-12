Function Get-DatabricksClusters 
{ 
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$BearerToken, 
        [parameter(Mandatory = $true)][string]$Region,
        [parameter(Mandatory = $false)][string]$ClusterId
    ) 

<#

.EXAMPLE
$cluster = Get-DatabricksClusters -BearerToken $BearerToken -Region $Region
$state = ($cluster | Where-Object {$_.cluster_id -eq $ClusterId }).state
if ($state -eq "TERMINATED"){
    Start-DatabricksCluster -Region $Region -BearerToken $BearerToken -ClusterId $ClusterId
}
#>
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $InternalBearerToken =  Format-BearerToken($BearerToken) 
    $Region = $Region.Replace(" ","")
    
    Try {
        $Clusters = Invoke-RestMethod -Method Get -Uri "https://$Region.azuredatabricks.net/api/2.0/clusters/list" -Headers @{Authorization = $InternalBearerToken}
    }
    Catch {
        Write-Output "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Output "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Error $_.ErrorDetails.Message
    }

    if ($PSBoundParameters.ContainsKey('ClusterId')){
        $Result = $Clusters.clusters | Where-Object {$_.cluster_id -eq $ClusterId}
        Return $Result
    }
    else {
        Return $Clusters.clusters
    }

}
    