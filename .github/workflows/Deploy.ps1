param (
  [Parameter(Mandatory)]
  [string] $nugetApiKey
)

$moduleName   = "SpoI18n";
$manifestPath = "./SpoI18n.psd1";

# Get last PSGallery module version
$remoteVersion = (Find-Module  -Name $moduleName `
                              -Repository PSGallery).Version;

Write-Host "PSGallery version: $remoteVersion";

# Get powershell metadata
$manifest = Import-PowerShellDataFile $manifestPath;

# Get current version [string]
$currentVersion = $manifest.ModuleVersion;
Write-Host "Current version: $currentVersion";

# If current version is greater than remote version, it'll be published
if ( $currentVersion.CompareTo($remoteVersion) -gt 0 ) {
  Write-Host "Current version is greater than remote version";

  Publish-Module -Path ./ -NuGetApiKey $nugetApiKey;

  exit 0;
} else {
  $errorMsg = "Current version is less or equal to remote version. No need to deploy.";
  Write-Error $errorMsg;
  throw $errorMsg;
}