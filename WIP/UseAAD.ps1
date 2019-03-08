function getBearer([string]$TenantID, [string]$ClientID, [string]$ClientSecret)
{
    [cmdletbinding()]
  #$TokenEndpoint = {https://login.windows.net/{0}/oauth2/token} -f $TenantID 
  $TokenEndpoint = {https://login.microsoftonline.com/{0}/oauth2/authorize} -f $TenantID 
  #$ARMResource = "https://management.core.windows.net/";
  $ARMResource = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d";

  $Body = @{
          'resource'= $ARMResource
          'client_id' = $ClientID
          'grant_type' = 'client_credentials'
          'client_secret' = $ClientSecret
          'response_type' = 'code'
          'response_mode' = 'query'
          'state' = 1234
          'redirect_uri' = 'http%3a%2f%2flocalhost'
  }

  $Body = @{
    'resource'= $ARMResource
    'client_id' = $ClientID
    'username' = 'simon@datathirst.net'
    'password' = ''
}

  # https://login.microsoftonline.com/75e26db8-ef63-42c8-ac89-fbeea21dfe71/oauth2/authorize?client_id=35d84174-03db-448e-a4e8-45aa7c8b96c6&response_type=code&redirect_url=http%3a%2f%2flocalhost&response_mode=query&resource=2ff814a6-3304-4ab8-85cb-cd0e6f879c1d&state=1423


  $params = @{
      ContentType = 'application/x-www-form-urlencoded'
      Headers = @{'accept'='application/json'}
      Body = $Body
      Method = 'Post'
      URI = $TokenEndpoint
  }

  $token = Invoke-RestMethod @params

  Return "Bearer " + ($token.access_token).ToString()
}

$ClientID       = "f734480f-1630-459f-9bde-bba555b39976" 
$ClientSecret   = "R/7QquN5a8YsWr+T2o4GD+dzTbfuZBeIKoVpB42smU0=" 
$token = getBearer "75e26db8-ef63-42c8-ac89-fbeea21dfe71" $ClientID $ClientSecret
Write-Output $token

return

Import-Module Az

Get-AzCachedAccessToken

$tenantId = "75e26db8-ef63-42c8-ac89-fbeea21dfe71"
$tokenCache = (Get-AzContext).TokenCache
$cachedTokens = $tokenCache.ReadItems() `
        | where { (($_.TenantId -eq $tenantId) -and ($_.resource -eq "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d")) } `
        | Sort-Object -Property ExpiresOn -Descending
$accessToken = $cachedTokens[0].AccessToken


$accessToken = "AQABAAIAAACEfexXxjamQb3OeGQ4GugvQz4GHIc1E8JQAj7mWg_1syArw0KzAHURVVo5laI-mkewoENT4K2Ss9Dewd_pjbmIn__eySmOMcxxFlAsxoi9_IXh9wbrdrDQsKOXyLWclaIMD-HkcXIxVFHceBk0Nxf31PjYW0PXbW-LHPJDJSwNlcTtHy-rjFCewTkxs9mbVEXmasl1-2RR600VzmsUpztd1SmmODOKG2sFE2lFMdUSCo_C1fxFOSloQE-ySsqy1B5Lztr8RlXv5S44ODOTItI6sLlRZkq9rnO-vBdpcgh6KXgIEp5_RaIQb1-mQfEz-B4nXTVMVnGLjEa2_PZPA0wF7ZKnrH5KaD1kS-4CV5azodUcmzCCT7mZ5sRcIZq_wHSs-BTy0Dh3Zc6HCWr2PP2cEvvSZWp0sQlyaF7tTozBve6ccOCLdT3wb33hscUhdFjLVloiqPBgNYUXqwjfTfOIiwcYjg9aeLGtasZOm7SWVefGerqOAp_m2xQ08OwThHMwMi9DnDFJR3zOJUscohhV22lxn4U97M5yhD06uaKBIen5tbsEctSD87GPYq0H-jatsWGYqZlwsGrftf03hwYXZdq3c4bbYncRM_IqeI6ChiAA"



$token = "Bearer " + $accessToken

$Region = "westeurope"
$URI = "https://$Region.azuredatabricks.net/api/2.0/clusters/list"
$Clusters = Invoke-RestMethod -Method Get -Uri $URI -Headers @{Authorization = $token; "X-Databricks-Org-Id" = "2930652350087280"}

$Clusters