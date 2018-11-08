
Set-Location $PSScriptRoot
Invoke-Pester -Script ./*.tests.ps1
Set-Location $PSScriptRoot