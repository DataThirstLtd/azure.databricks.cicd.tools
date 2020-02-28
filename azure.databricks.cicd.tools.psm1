#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Export Public functions
Export-ModuleMember -Function $Public.Basename
Export-ModuleMember -Alias * -Function *

if ($PSVersionTable.PSVersion.Major -lt 7) {
    $checkThreadJob = Get-InstalledModule -Name "ThreadJob" -MinimumVersion "2.0.3" -ErrorAction SilentlyContinue
    if ($null -eq $checkThreadJob) {
        Install-Module -Name ThreadJob -RequiredVersion 2.0.3 -Force -Scope CurrentUser
    }
    $checkThreadJob = Get-InstalledModule -Name "ThreadJob" -MinimumVersion "2.0.3" -ErrorAction SilentlyContinue
    if($null -eq $checkThreadJob){
        Write-Error "oh dear thread job not installed"
    }
}