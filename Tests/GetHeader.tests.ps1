Set-Location $PSScriptRoot
Import-Module "..\Private\GetHeaders.ps1" -Force
Import-Module "..\Private\ConnectFunctions.ps1" -Force
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force


$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

$BearerToken = $Config.BearerToken
$Region = $Config.Region


Describe "GetHeader Functions" {
    
    It "GetHeaders valid"{
        Set-GlobalsNull

        $Params = @{"BearerToken"=$BearerToken; "Region"=$Region}
        $x = GetHeaders($Params)
        $x | Should -Not -Be $null
    }

}
