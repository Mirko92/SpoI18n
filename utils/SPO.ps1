# Connect to a Sharepoint Site 
function Connect-Spo {
  param (
    [string] $siteUrl
  )

  Connect-PnPOnline -Interactive -Url $siteUrl;

  $siteTitle = Get-PnPSite | Select-Object Title; 

  Write-Host "Connected to $siteTitle";
}