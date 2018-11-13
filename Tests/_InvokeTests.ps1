

$PSVersionTable

Get-Module
Install-Module Pester -MinimumVersion 4.4.2 -Force -Scope CurrentUser -SkipPublisherCheck
Import-Module Pester -MinimumVersion 4.4.2
Get-Module
Set-Location $PSScriptRoot
Invoke-Pester -Script ./*.tests.ps1 -OutputFile TestResults.xml -OutputFormat NUnitXML
Set-Location $PSScriptRoot