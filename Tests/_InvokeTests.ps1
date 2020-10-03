param(
    [ValidateSet('Bearer','ServicePrincipal')][string]$Mode="Bearer"
)
Install-Module Pester -MinimumVersion 4.4.2 -MaximumVersion 4.10.1 -Scope CurrentUser -SkipPublisherCheck -Force
Import-Module Pester -MinimumVersion 4.4.2 -MaximumVersion 4.10.1

Set-Location $PSScriptRoot
$Edition = $PSVersionTable.PSEdition
Invoke-Pester -Script @{Path = "./*.tests.ps1"; Parameters = @{mode=$Mode}} -OutputFile "TestResults-$Edition-$Mode.xml" -OutputFormat NUnitXML
Set-Location $PSScriptRoot