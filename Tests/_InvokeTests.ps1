param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="ServicePrincipal"
)
Install-Module Pester -MinimumVersion 4.4.2 -Scope CurrentUser -SkipPublisherCheck
Import-Module Pester -MinimumVersion 4.4.2

Set-Location $PSScriptRoot
$Edition = $PSVersionTable.PSEdition
Invoke-Pester -Script @{Path = "./*.tests.ps1"; Parameters = @{mode=$Mode}} -OutputFile "TestResults-$Edition-$Mode.xml" -OutputFormat NUnitXML
Set-Location $PSScriptRoot