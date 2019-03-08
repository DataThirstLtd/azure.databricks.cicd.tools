#Install the ADAL.PS package if it's not installed.
if(!(Get-Package adal.ps)) { Install-Package -Name adal.ps }

$authority = "https://login.windows.net/common/oauth2/authorize" 
#Clear-ADALAccessTokenCache -AuthorityName $authority
#this is the security and compliance center endpoint
$resourceUrl = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
#replace <application-id> and <redirect-uri>, with the Redirect URI and Application ID from your Azure AD application registration.
$clientId = "b98a311c-afad-41f8-9ccf-b1924146088a"
$redirectUri = "http://localhost"

$response = Get-ADALToken -Resource $resourceUrl -ClientId $clientId -RedirectUri $redirectUri -Authority $authority -PromptBehavior:Auto
$accessToken = $response.AccessToken 

$token = "Bearer " + $accessToken

$Region = "westeurope"
$URI = "https://$Region.azuredatabricks.net/api/2.0/clusters/list"
$Clusters = Invoke-RestMethod -Method Get -Uri $URI -Headers @{Authorization = $token; "X-Databricks-Org-Id" = "2930652350087280"}

$Clusters

Get-AzureRMContext

Import-Module AzureAD

Connect-AzureAD

$app = New-AzureADApplication -DisplayName "demo4" -PublicClient $true -ReplyUrls "http://localhost" -Homepage "http://localhost"


$DatabricksAPI = (Get-AzureADServicePrincipal -SearchString AzureDatabricks)

$DatabricksAPI.Oauth2Permissions | select Id,AdminConsentDisplayName,Value

$req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$acc1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "739272be-e143-11e8-9f32-f2801f1b9fd1","Scope"
$req.ResourceAccess = $acc1
$req.ResourceAppId = $DatabricksAPI.AppId
Set-AzureADApplication -ObjectId $app.Objectid -RequiredResourceAccess $req




New-AzureRmADApplication -DisplayName "demowebrequest" -HomePage "http://localhost" `
    -IdentifierUris "https://www.stranger.nl/demowebrequest" -ReplyUrls "http://localhost"

New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId
New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $app.ApplicationId.Guid

Get-AzureRmADApplication -DisplayNameStartWith 'demowebrequest' -OutVariable app
Get-AzureRmADServicePrincipal -ServicePrincipalName $app.ApplicationId.Guid -OutVariable SPN

