param(
    [ValidateSet('Bearer', 'ServicePrincipal')][string]$Mode = "ServicePrincipal"
)

Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psd1" -Force
$Config = (Get-Content '.\config.json' | ConvertFrom-Json)

switch ($mode) {
    ("Bearer") {
        Connect-Databricks -Region $Config.Region -BearerToken $Config.BearerToken
    }
    ("ServicePrincipal") {
        Connect-Databricks -Region $Config.Region -DatabricksOrgId $Config.DatabricksOrgId -ApplicationId $Config.ApplicationId -Secret $Config.Secret -TenantId $Config.TenantId
    }
}

$DatabricksPath = "/Shared/UnitTestImport"

Describe "Import-DatabricksFolder" {
    BeforeAll {
        Import-DatabricksFolder `
            -LocalPath 'Samples\DummyNotebooks' -DatabricksPath $DatabricksPath `
            -Verbose
    }
    it "Delete single item" {
        Remove-DatabricksNotebook -Path '/Shared/UnitTestImport/SubFolder/File3'
    }

    it "Delete Folder with Recurse" {
        Remove-DatabricksNotebook -Path $DatabricksPath -Recursive
    }

    it "Retries on First 429 Error" {
        $script:MockInvokeRequestCalled = 0
        $MockInvokeRestMethod = {
            $script:MockInvokeRequestCalled++                                
            if ($script:MockInvokeRequestCalled -eq 1) {
                $errorDetails = '{"code": 1, "message": "Too Many Requests", "more_info": "", "status": 429}'
                $statusCode = 429
                $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
                $exception = New-Object Microsoft.PowerShell.Commands.HttpResponseException "$statusCode ($($response.ReasonPhrase))", $response
                $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                $errorID = 'WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand'
                $targetObject = $null
                $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $errorCategory, $targetObject
                $errorRecord.ErrorDetails = $errorDetails
                Throw $errorRecord
            }
            else {
                return $true
            }
        }
        Mock -CommandName Invoke-RestMethod -MockWith $MockInvokeRestMethod
        {Remove-DatabricksNotebook -Path $DatabricksPath} | Should not Throw
        Assert-MockCalled Invoke-RestMethod -Times $MockInvokeRequestCalled
    }

    it "Throws on Second 429 Error" {
        Mock Invoke-RestMethod{
            $errorDetails = '{"code": 1, "message": "Too Many Requests", "more_info": "", "status": 429}'
            $statusCode = 429
            $response = New-Object System.Net.Http.HttpResponseMessage $statusCode
            $exception = New-Object Microsoft.PowerShell.Commands.HttpResponseException "$statusCode ($($response.ReasonPhrase))", $response
            $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
            $errorID = 'WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand'
            $targetObject = $null
            $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $errorCategory, $targetObject
            $errorRecord.ErrorDetails = $errorDetails
            Throw $errorRecord
        }
        { Remove-DatabricksNotebook -Path $DatabricksPath } | Should Throw
    }
}
