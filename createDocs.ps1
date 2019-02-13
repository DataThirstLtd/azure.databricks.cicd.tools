$reset=$true

Install-Module platyPS -Scope CurrentUser
Import-Module platyPS
Set-Location $PSScriptRoot

Import-Module .\azure.databricks.cicd.tools.psm1 -Force

if ($reset){
    New-MarkdownHelp -Module azure.databricks.cicd.tools -OutputFolder ..\azure.databricks.cicd.tools.wiki -force -WithModulePage
}
else {
    Update-MarkdownHelp ..\azure.databricks.cicd.tools.wiki
}
