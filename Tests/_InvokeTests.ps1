
Set-Location $PSScriptRoot
Invoke-Pester -Script ./*.tests.ps1 -OutputFile TestResults.xml -OutputFormat NUnitXML
Set-Location $PSScriptRoot