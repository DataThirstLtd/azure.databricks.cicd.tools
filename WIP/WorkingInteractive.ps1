
$tenantId = "75e26db8-ef63-42c8-ac89-fbeea21dfe71"
$clientId = "b98a311c-afad-41f8-9ccf-b1924146088a"
$redirectUrl = "http%3A%2F%2Flocalhost"
$resourceId = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

$Manual = "https://login.microsoftonline.com/$tenantId/oauth2/authorize?client_id=$clientId&response_type=code&redirect_url=$redirectUrl&response_mode=query&resource=$resourceId&state=123456"

Write-output $Manual


$code = "AQABAAIAAACEfexXxjamQb3OeGQ4GugvQ2B-wK8OsJkx3qN42y0ciMLhTfGbcnpeltmBxPkeUjS9vpnjdUUbCq3gKOheC-HVrM1ddBfTqRFNH95qFmmwydvwS2gzcM18hhWKPNnjar4TnSphuLmcgkwwnWNw3eBoBVTRwUVtZ93n_qMdAHGRu0Dbxg-vCPDM3ys0DJfTob9Zczp2KJYxT99nMe2O5jWtMz_aE-SnBZACvr8da8xMpXYT_rpRzTCCF1loG2KQenzXY4VkvdEW_mu17rszYmMd_COzAehEWk76bv_Ar97Xh4VUFpPug_q8ndwmNtCyB-FtIMcUwJBxfzDGRPgwYoh08Lh-jKSCcUkB4chqCfTSzzwO9DdiYNI4NBSLUGREy5Jggm5mcxmGP6cSLpe05gjkGvyp6E0cNlgBWhObzdyx51oH6cozkaVaij2SmgO9w-HJMQvwyVoFcEdVgx0fJ8mnPM3tGq2R9D27k5Y2fyHiiYHEcbuDS1kxvhrLJVYQ7iKwTN0T89jh4QOMw4xyWAUSHUvbP_t-s4qLJllCOl6WmsTEUUntoHtIbszul-OyjsSAHiu884TGDjjP4NQ60eRf7PDPNiTYu29vyQRNrZmmUyAA"

$BodyText="grant_type=authorization_code&client_id=$clientId&code=$code&redirect_uri=$redirectUrl&resource=$resourceId"
$URI = "https://login.microsoftonline.com/$tenantId/oauth2/token/"

$Response = Invoke-RestMethod -Method Post -Body $BodyText -Uri $URI -ContentType application/x-www-form-urlencoded


$Response 


$token = "Bearer " + $Response.access_token

$Region = "westeurope"
$URI = "https://$Region.azuredatabricks.net/api/2.0/clusters/list"
$Clusters = Invoke-RestMethod -Method Get -Uri $URI -Headers @{Authorization = $token; "X-Databricks-Org-Id" = "2930652350087280"}

$Response 


$Res = "http://localhost/?code=AQABAAIAAACEfexXxjamQb3OeGQ4GugvsLppJphrH__3hHd9O7DL6q7VOfD8tAsVpr1-htMfnxP_uhE5YZIUY6WSsMUxI0dJ8aL8R-UqGQPE7rxxcjOZ1d5GHZeWp1043g7hn10KaoAAw7Ccv_wfrfU9tDsHFnTLs3yLx-rUOKMs-crhlSjPwPGneCytA33lViZvEt__LJza5RcpmKyrh8unlgPmN2zP7-YVANjd7OpGoxikMEmWEpRi9n8RJsW5jxYekVcwq_2PyQaJxuZqcaKLzvD52H1d8Kt8KONS9v-1wViunVQr9ddXXV-DUNoLEiIflIypFzfT6MrrYcoHe8PNcvbg7kg3T2FuMD5sUyPovjXzLgDVsNDpBBKHuKhWOwEPeN0I4a8RFEXsvUgkJSCa_qWLJVAwQUT5QLsFBeBuFNAc-C12ujYEp2nKG56WTtX5Rr2S3jQ2uV7BTTJXgSdPk_AfCS8MCAMjb7L4Vt4D-6LvQcmMRlq7mA6gkZJH0wEmbYisl8FU2KTKjaAl7Ggtvz_DEg7-L_Xe6KURGfwNeUxwB8HzK4U_TlgulAq-HVebwkrXwsJRljpSQVirOcgnVmvHw7IJC13fWTJ4xbzJTI5ZlVVxLCAA&state=987654321&session_state=8059940e-763a-49ef-b8b9-80db9e807f09"

$sCode = $Res.Substring($Res.IndexOf("?code=") + 6, ($Res.Length - ($Res.IndexOf("?code=") + 6) ) )


