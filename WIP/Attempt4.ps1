Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.Tools.psd1" -Force
 #$BearerToken = Get-Content "MyBearerToken.txt"  # Create this file in the Tests folder with just your bearer token in
$Region = "westeurope"

Connect-Databricks -DatabricksOrgId "2930652350087280" -ClientId "b98a311c-afad-41f8-9ccf-b1924146088a" -Region $Region
Get-DatabricksClusters # -BearerToken $BearerToken -Region $Region


$currentAzureContext = Get-AzContext
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile);
$accessToken = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken;




$ClientID = "b98a311c-afad-41f8-9ccf-b1924146088a"
$tenantId = "75e26db8-ef63-42c8-ac89-fbeea21dfe71"
$RedirectURL = "https%3A%2F%2Flocalhost%3A12345"
$URI = "https://login.microsoftonline.com/$tenantId/oauth2/token/"
$ResourceID = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
$Headers = @{"Content-Type" = "application/x-www-form-urlencoded"}
$Body = @{}
#$Body['grant_type']='authorization_code'
$Body['client_id']="b98a311c-afad-41f8-9ccf-b1924146088a"
$Body['code'] = $accessToken 
$Body['redirect_uri'] = "http://localhost"
$Body['resource'] = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

$BodyText = "grant_type=authorization_code&code=$accessToken&client_id=$ClientID&redirect_uri=$RedirectURL&resource=$ResourceID&client_secret=passw0rd"
#$BodyText = $Body | ConvertTo-Json -Depth 10

Invoke-RestMethod -Method Post -Body $BodyText -Uri $URI -ContentType application/x-www-form-urlencoded

#grant_type=authorization_code
#&client_id=2d4d11a2-f814-46a7-890a-274a72a7309e
#&code=AwABAAAAvPM1KaPlrEqdFSBzjqfTGBCmLdgfSTLEMPGYuNHSUYBrqqf_ZT_p5uEAEJJ_nZ3UmphWygRNy2C3jJ239gV_DBnZ2syeg95Ki-374WHUP-i3yIhv5i-7KU2CEoPXwURQp6IVYMw-DjAOzn7C3JCu5wpngXmbZKtJdWmiBzHpcO2aICJPu1KvJrDLDP20chJBXzVYJtkfjviLNNW7l7Y3ydcHDsBRKZc3GuMQanmcghXPyoDg41g8XbwPudVh7uCmUponBQpIhbuffFP_tbV8SNzsPoFz9CLpBCZagJVXeqWoYMPe2dSsPiLO9Alf_YIe5zpi-zY4C3aLw5g9at35eZTfNd0gBRpR5ojkMIcZZ6IgAA
#&redirect_uri=https%3A%2F%2Flocalhost%3A12345
#&resource=https%3A%2F%2Fservice.contoso.com%2F


$token = "Bearer " + $accessToken

$Region = "westeurope"
$URI = "https://$Region.azuredatabricks.net/api/2.0/clusters/list"
$Clusters = Invoke-RestMethod -Method Get -Uri $URI -Headers @{Authorization = $token; "X-Databricks-Org-Id" = "2930652350087280"}
