#
# Module manifest for module azure.databricks.cicd.tools'
#
# Generated by: Simon D'Morias @ Datathirst.net
#
# Generated on: 09/07/2018
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'azure.databricks.cicd.tools.psm1'

    # Version number of this module.
    ModuleVersion = '1.1.21'

    # ID used to uniquely identify this module
    GUID = 'b277a688-f588-434c-a1dc-a44ff2105279'

    # Author of this module
    Author = "Simon D'Morias"

    # Company or vendor of this module
    CompanyName = 'Data Thirst Ltd'

    # Copyright statement for this module
    Copyright = 'Data Thirst Ltd 2019'

    # Description of the functionality provided by this module
    Description = 'PowerShell module to help with Azure Databricks CI & CD Scenarios by simplifying the API or CLI calls into idempotent commands. See https://github.com/DataThirstLtd/azure.databricks.cicd.tools & https://datathirst.net'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @('')

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = 'path.ps1xml'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = 'Add-DatabricksSecretScope', 'Export-DatabricksFolder', 'Import-DatabricksFolder', 
    'Set-DatabricksSecret', 'Get-DatabricksClusters', 'Get-DatabricksNodeTypes', 'Get-DatabricksSparkVersions', 
    'New-DatabricksCluster', 'Remove-DatabricksCluster', 'Start-DatabricksCluster', 'Stop-DatabricksCluster', 
    'Update-DatabricksClusterResize', 'Add-DatabricksDBFSFile', 'Add-DatabricksLibrary', 'Add-DatabricksNotebookJob',
    'Get-DatabricksDBFSFolder', 'Get-DatabricksJobs', 'Get-DatabricksLibraries', 'Remove-DatabricksDBFSItem',
    'Remove-DatabricksJob', 'Add-DatabricksSparkSubmitJob', 'Add-DatabricksPythonJob', 'Add-DatabricksJarJob',
    'Add-DatabricksDBFSFolder', 'Get-DatabricksDBFSFile', 'Get-DatabricksRun', 'Get-DatabricksJobId',
    'Add-DatabricksGroup', 'Add-DatabricksMemberToGroup', 'Get-DatabricksGroupMembers', 'Get-DatabricksGroups',
    'Remove-DatabricksSecretScope', 'Remove-DatabricksGroup', 'Restart-DatabricksCluster', 'Get-DatabricksSecretScopes',
    'Start-DatabricksJob', 'Get-DatabricksJobRun', 'Get-DatabricksJobRunList', 'Remove-DatabricksNotebook',
    'Remove-DatabricksLibrary'

    # Cmdlets to export from this module
    CmdletsToExport = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module
    AliasesToExport = '*'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @("Databricks", "Azure", "DevOps", "Deploy", "DBFS", "Cluster", "Jobs")

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/DataThirstLtd/azure.databricks.cicd.tools'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/DataThirstLtd/azure.databricks.cicd.tools'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

    }
