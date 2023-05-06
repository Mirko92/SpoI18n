$manifestPath = "./SpoI18n.psd1";

# Get powershell metadata
$manifest = Import-PowerShellDataFile $manifestPath;

# Get current version [string]
$currentVersion = $manifest.ModuleVersion;

Write-Host "Current version: $currentVersion";

# Version parts 
$versionParts = $currentVersion.Split('.');

# Increment version 
$versionParts[-1] = [int]::Parse($versionParts[-1]) + 1;

# Save new version
$newModuleVersion = [string]::Join(".", $versionParts);

Write-Host "New version: $newModuleVersion";

Update-ModuleManifest   -Path  $manifestPath `
                        -ModuleVersion $newModuleVersion;
