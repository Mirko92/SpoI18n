#
# Module manifest for module 'SpoI18n'
#
# Generated by: Mirko Petrelli
#
# Generated on: 17-Oct-22
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'SpoI18n'

# Version number of this module.
ModuleVersion = '0.1.8'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '5363cffe-111c-4eff-977c-78a68f6740b2'

# Author of this module
Author = "Mirko Petrelli"

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) Mirko Petrelli. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A Powershell module to easy handle i18n in SharePoint online sites.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.0.0'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    "PnP.Powershell"
)

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    "Get-SpoI18nCsv",
    "ConvertFrom-SpoI18nCsv",
    "Copy-SpoI18nCsv"
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
#CmdletsToExport = @(
#    "Get-I18nSiteCsv",
#    "ConvertFrom-SpoI18nCsv",
#    "Copy-SpoI18nCsv"
#)

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
    "assets/_seed.resx"
    "assets/Locales.json"
    "utils/Locales.ps1"
    "utils/SPO.ps1"
    "ConvertFrom-SpoI18nCsv.ps1"
    "Copy-SpoI18nCsv.ps1"
    "Get-SpoI18nCsv.ps1"
    "SpoI18n.psd1"
    "SpoI18n.psm1"
    "SpoI18nCsvWriter.ps1"
    "LICENSE"
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

