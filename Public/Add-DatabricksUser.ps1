<#

.SYNOPSIS
    Add a user to Databricks workspace with entitlements and groups
    
.DESCRIPTION
    Add a user to Databricks workspace with entitlements and groups. If the user exists the error will be ignored but note that the entitlments and groups requested will not be applied

.PARAMETER BearerToken
    Your Databricks Bearer token to authenticate to your workspace (see User Settings in Databricks WebUI)

.PARAMETER Region
    Azure Region - must match the URL of your Databricks workspace, example northeurope

.PARAMETER Username
    Email address (matched to AAD) for the user

.PARAMETER Entitlements
    List of entitlements for the user (such as allow-cluster-create )

.PARAMETER Groups
    List of GroupId's to be added to (See Get-DatabricksGroups)

.EXAMPLE 
    C:\PS> Add-DatabricksUser -BearerToken $BearerToken -Region $Region -Username BillyBob@datathirst.net

    This example creates a group called acme

.NOTES
    Author: Simon D'Morias/Data Thirst Ltd

#>

Function Add-DatabricksUser
{
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$false)][string]$BearerToken,
        [parameter(Mandatory=$false)][string]$Region,
        [parameter(Mandatory=$true)][string]$Username,
        [parameter(Mandatory=$false)][string[]]$Entitlements,
        [parameter(Mandatory=$false)][string[]]$Groups
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $Headers = GetHeaders $PSBoundParameters
    
    $uri = "$global:DatabricksURI" + (Get-SCIMURL "Users")
    $schemaR = Add-SCIMSchema "urn:ietf:params:scim:schemas:core:2.0:User"
    $entitlementsR = (Add-SCIMValueArray "entitlements" $Entitlements)
    $groupsR = (Add-SCIMValueArray "groups" $Groups)
    $usernameR = @{"userName"=$Username}

    $Body = ($schemaR + $EntitlementsR+ $usernameR + $groupsR) | ConvertTo-Json -Depth 10 

    Try {
        $Request = Invoke-RestMethod -Method Post -Body $Body -Uri $uri -Headers $Headers -ContentType "application/scim+json"
    }
    Catch {
        if ($_.Exception.Response -eq $null) {
            throw $_.Exception.Message
        } else {
            if ($_.Exception.Response.StatusCode.value__ -eq 409){
                Write-Warning "User exists - entitlements and groups may differ to requested"
            }
            else {
                throw $_.ErrorDetails.Message
            }    
        }  
    }

    return $Request
}
