$reset=$true

Install-Module platyPS -Scope CurrentUser
Import-Module platyPS
Set-Location $PSScriptRoot

Import-Module .\azure.databricks.cicd.tools.psd1 -Force

if ($reset){
    $files = Get-ChildItem .\Public -Filter *.ps1
    foreach ($f in $files){
        New-MarkdownHelp -Command $f.BaseName -OutputFolder ..\azure.databricks.cicd.tools.wiki -force
    }
}
else {
    Update-MarkdownHelp ..\azure.databricks.cicd.tools.wiki
}



