Install-Module Pester -MinimumVersion 4.4.2 -Scope CurrentUser -SkipPublisherCheck
Import-Module Pester -MinimumVersion 4.4.2

Set-Location $PSScriptRoot
$Edition = $PSVersionTable.PSEdition
Invoke-Pester -Script ./*.tests.ps1 -OutputFile "TestResults-$Edition.xml" -OutputFormat NUnitXML
Set-Location $PSScriptRoot