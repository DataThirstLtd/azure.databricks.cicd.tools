$reset=$true

Import-Module platyPS
Set-Location $PSScriptRoot

Import-Module .\azure.databricks.cicd.tools.psm1 -Force

if ($reset){
    New-MarkdownHelp -Module azure.databricks.cicd.tools -OutputFolder ..\md -force
}
else {
    Update-MarkdownHelp ..\md
}
