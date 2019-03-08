


$authority = "https://login.windows.net/common/oauth2/authorize" 
#this is the security and compliance center endpoint

#replace <application-id> and <redirect-uri>, with the Redirect URI and Application ID from your Azure AD application registration.
$clientId = "b98a311c-afad-41f8-9ccf-b1924146088a"
$redirectUri = "http://localhost/12345"
$tenantId = "75e26db8-ef63-42c8-ac89-fbeea21dfe71"

$databricksStaticGuid = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
$TokenEndpoint = {https://login.windows.net/{0}/oauth2/authorize} -f $TenantID 

$Body = @{}
$Body['resource'] = $databricksStaticGuid
$Body['client_id'] = $clientId 
$Body['response_type'] = "code"
$Body['response_mode'] = "query"
$Body['state'] = "1234"
$Body['redirect_uri'] = $redirectUri 

$params = @{
    ContentType = 'application/x-www-form-urlencoded'
    Headers = @{'accept'='application/json'}
    Body = $Body
    Method = 'Get'
    URI = $TokenEndpoint
}

$token = Invoke-RestMethod @params

$token




#https://login.microsoftonline.com/75e26db8-ef63-42c8-ac89-fbeea21dfe71/oauth2/authorize?client_id=b98a311c-afad-41f8-9ccf-b1924146088a&response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A12345&response_mode=query&resource=2ff814a6-3304-4ab8-85cb-cd0e6f879c1d&state=12345