
$tenantId = "75e26db8-ef63-42c8-ac89-fbeea21dfe71"
$clientId = "b98a311c-afad-41f8-9ccf-b1924146088a"
$redirectUrl = "http%3A%2F%2Flocalhost"
$resourceId = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

$Manual = "https://login.microsoftonline.com/$tenantId/oauth2/authorize?client_id=$clientId&response_type=code&redirect_url=$redirectUrl&response_mode=query&resource=$resourceId&state=123456"

write-output $Manual

$code = "AQABAAIAAACEfexXxjamQb3OeGQ4GugvhtBfectIzIY965MUSm3trpeejCM6yMFS78YJkAX0g2epQ6RJFpCtfPEMHegfJ3_ZxzC-QY6DKxBNcVPqV63hyu9sPNz6e6tWUBv-4A-kruZwrpsnIHjQG6tlYDdkHmPKO7xe--m7kTUB__nF4BvlhcK9GRFNe_nLfHsIM0iNp6pJWn4C8RymG_6LaqBuOUOS-ssHfz5tWhuocLn38G_wWj_MoJmuoFU1qUjMHU1UEJTZM09jFNNOdJD-Xh85as8vJ5b13RdKviSyUVD5jaKZiy9azMLwwgChpxQxKz2p15N49AaY8doM9rjPQDS34dEMyc68DDHOBISQTBbxlJZWPFj-BCQtdxodz8Kv3q1hRzOzILFgSThWl-GEQYF0AN2-hlmAn_334Hm5EFKEyfJeqgDt_dwmTN0dSSrzSDeeBliUvAI3EC4OZIBGhxXufM999aSj711QyWZ0kK4rE5MPFYM3K7jTrcRWJ4z1ZDe95RRV67mFAID-7YH6EdjUqPQh98iDXksDlwzWhEqYty5L3KTcIYAEAeYJus4S3LW8ZQ7fL0ZOYSjhJ3KQEbrxtdeis8cSmkZyTb3niP_Q-ptoAyAA"


$BodyText="grant_type=authorization_code&client_id=$clientId&code=$code&redirect_uri=$redirectUrl&resource=$resourceId"
$URI = "https://login.microsoftonline.com/$tenantId/oauth2/token/"

$Response = Invoke-RestMethod -Method Post -Body $BodyText -Uri $URI -ContentType application/x-www-form-urlencoded


$Response 


$token = "Bearer " + $Response.access_token

$Region = "westeurope"
$URI = "https://$Region.azuredatabricks.net/api/2.0/clusters/list"
$Clusters = Invoke-RestMethod -Method Get -Uri $URI -Headers @{Authorization = $token; "X-Databricks-Org-Id" = "2930652350087280"}

$Response 
