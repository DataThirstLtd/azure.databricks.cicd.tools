
$tenantId = "75e26db8-ef63-42c8-ac89-fbeea21dfe71"
$clientId = "356c2ab9-d4f0-4ece-8ec1-c274083fc38a"
$redirectUrl = "http%3A%2F%2Flocalhost"
$resourceId = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
$secret = "947JF1k0KQlK67kxwLaQonipWBy7DEBXCUbYU9hlRIk="

# app-Databricks
$clientId = "b98a311c-afad-41f8-9ccf-b1924146088a"
$secret = "tR7!5=st}(6!ybs){2|6;.>!g!u;m|UL%lj^?#>91&d/%[S}[I_.X?@+>1[A)"

# DatabricksTestEntApp
#$clientId = "e7d7948c-8167-463f-abd0-00c3cb6cb452"
#$secret = "-h0nFN^R^j6vRH_kW[yQ+.)/V"

$Auto = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$BodyText = "client_id=$clientId&grant_type=client_credentials&client_secret=$secret&scope=$resourceId/.default"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Method Post -Uri $Auto -Body $BodyText -ContentType application/x-www-form-urlencoded

write-output $Response

$code = $Response.access_token


$BodyText="grant_type=authorization_code&client_id=$clientId&code=$code&redirect_uri=$redirectUrl&resource=$resourceId"
$URI = "https://login.microsoftonline.com/$tenantId/oauth2/token/"

$Response2 = Invoke-RestMethod -Method Post -Body $BodyText -Uri $URI -ContentType application/x-www-form-urlencoded


$Response2


$token = "Bearer " + $Response.access_token

$Region = "westeurope"
$URI = "https://$Region.azuredatabricks.net/api/2.0/clusters/list"
$Clusters = Invoke-RestMethod -Method Get -Uri $URI -Headers @{Authorization = $token; "X-Databricks-Org-Id" = "2930652350087280"}

$Response 
