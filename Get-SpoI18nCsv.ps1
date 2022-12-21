<#
.SYNOPSIS
Extract a CSV for ContentTypes, Fields, Lists of a SPO site.

.DESCRIPTION
CSV format: 
Key, Locale1,Comment.Locale1, Locale2,CommentLocale2, ...LocaleN,CommentLocaleN

In each "Locale" column you'll find the default item's DisplayName.
Replace values where needed and save the file. 

Pass the file to "ConvertFrom-SpoI18nCsv" to produce *.resx files.

.PARAMETER siteUrl
Site's URL, if not provided it will look for a PnPConnection and if exists it'll use it.
eg: "https:\\<tenant>.sharepoint.com\sites\<sitename>"

.PARAMETER outputPath
Output file destination

.PARAMETER locales
List of locales, including default locale, to translate the site.
eg. en-US, it-IT

.PARAMETER ctGroups
It allows you to restrict the ContenTypes number to translate.
eg: "Custom content types"

.PARAMETER fieldsPattern
It allows you to restrict the Fields number to translate;
Don't use wildcards, they will be added automatically at the begin and the end of pattern.
eg: "CUSTOM_"
TODO: Pattern implica che magari possa fargli usare una regex 

.PARAMETER lists
It allows you to specify wich lists you want to translate. 

.PARAMETER includeListViews
If set, all views in each list will be included in the file 

.EXAMPLE
Get-SpoI18nCsv  -siteUrl https://<tenant>.sharepoint.com/sites/<siteName> `
                -outputPath C:\Users\Desktop\<fileName>.csv `
                -locales en-US,it-IT,ur-PK `
                -ctGroups "Custome Content Types" `
                -fieldsPattern "CUSTOM_" `
                -lists "List one", "List Two";

.NOTES
General notes
#>
function Get-SpoI18nCsv {
  param (
    [string] $siteUrl,

    [Parameter(Mandatory)]
    [string] $outputPath,

    [Parameter(Mandatory)]
    [ArgumentCompleter({ LocaleArgumentCompleter @args })]
    [string[]] $locales,
    
    [string[]] $ctGroups,
    
    [string] $fieldsPattern,

    [string[]] $lists,

    [switch] $includeListViews
  )

  $localesInfo = Get-Locales | Where-Object { $_.label -in $locales };

  $csvWriter = [SpoI18nCsvWriter]::new($localesInfo);
  $csvWriter.AddHeader();

  if ($siteUrl) {
    Connect-Spo $siteUrl;
  } else {
    $isConnected = Get-PnPConnection; 
    if ($isConnected) {
      $siteUrl = (Get-PnPSite).Url;

      Write-Host "Connected to $siteUrl";
    }
  }

  
  #region FIELDS 
  $siteFields = if ($fieldsPattern) {
    Get-PnPField | Where-Object InternalName -Like "*$fieldsPattern*"
  } else {
    Get-PnPField
  } 
  $siteFields = $siteFields | Sort-Object InternalName;
  
  Write-Host "Found #$($siteFields.Count) Fields";

  foreach ($field in $siteFields) {
    Write-Host "Processing Field: $($field.Title)";

    $csvWriter.AddRow(
      "00000000000000000000000000000000_FieldTitle$($field.InternalName)", 
      $field.Title
    );
  }
  #endregion

  #region CONTENT TYPES  
  $siteCTS = if ($ctGroups.Count -gt 0) {
    (Get-PnPContentType | Where-Object Group -in $ctGroups)
  } else { 
    Get-PnPContentType;
  }
  $siteCTS = $siteCTS | Sort-Object Name;

  Write-Host "Found #$($siteCTS.Count) Content types";

  foreach ($ct in $siteCTS) {
    Write-Host "Processing CT: $($ct.Name)";

    $contentTypeName = $ct.Name;
    $contentTypeDesc = $ct.Description -eq "" ? "Descrizione $contentTypeName" : $ct.Description;

    $csvWriter.AddRow(
      "00000000000000000000000000000000_CTName$($ct.Id)", 
      $contentTypeName
    );
    $csvWriter.AddRow(
      "00000000000000000000000000000000_CTDesc$($ct.Id)", 
      $contentTypeDesc, 
      $true
    );
  }
  #endregion

  #### LISTS
  $siteLists = if ($lists.Count -gt 0) {
    (Get-PnPList | Where-Object Title -in $lists)
  } else {
    (Get-PnPList)
  }

  $siteLists = $siteLists | Sort-Object Title

  Write-Host "Found #$($siteLists.Count) Lists";

  foreach ($list in $siteLists) {
    Write-Host "Processing list: $($list.Title)";
    $listID = [string]$list.Id; 

    # List title 
    $listKey    = $list.Id.ToString().Replace("-", "");
    $csvWriter.AddRow(
      "$($listKey)_ListTitle", 
      $list.Title 
    );

    # List description 
    $listDescription = ($list.Description -eq "") ? "Descrizione lista $($list.Title)" : $list.Description;
    $csvWriter.AddRow(
      "$($listKey)_ListDescription", 
      $listDescription,
      $true 
    );
    
    #region CTS of the list
    $listCTS = Get-PnPContentType -List $listID | Sort-Object Name;
    Write-Host "Found #$($listCTS.Count) Content Types on this list";

    foreach ($listCT in $listCTS) {
      Write-Host "Processing CT: $($listCT.Name)";

      $csvWriter.AddRow(
        "$($listKey)_CTName$($listCT.Id)", 
        $listCT.Name
      );
      $csvWriter.AddRow(
        "$($listKey)_CTDesc$($listCT.Id)", 
        $listCT.Name, 
        $true
      );
    }
    #endregion

    #region FIELDS of the list
    $listFields = Get-PnPField -List $listID 
      | Where-Object InternalName -Like "*$fieldsPattern*"
      | Sort-Object InternalName;

    Write-Host "Found #$($listFields.Count) fields on this list";

    foreach ($listField in $listFields) {
      Write-Host "Processing field: $($listField.Title)";

      $csvWriter.AddRow(
        "$($listKey)_FieldTitle$($listField.InternalName)", 
        $listField.Title
      );
    }
    #endregion

    #region VIEWS of the list
    if ($includeListViews) {
      $listViews = Get-PnPView -List $listID | Sort-Object Title;

      foreach ($listView in $listViews) {
        Write-Host "Processing View: $($listView.Title)";
      
        $csvWriter.AddRow(
          "$($listKey)_ViewTitle{$($listView.Id.ToString().ToUpper())}", 
          $listView.Title
        );
      }
    }
    #endregion
  }

  $parentFolderPath = Split-Path $outputPath -Parent;
  if (!(Test-Path $parentFolderPath)) {
    New-Item $parentFolderPath -ItemType Directory
  }

  $csvResult = $csvWriter.csvResult;

  $csvResult | Export-Csv -Path "$outputPath" -UseQuotes AsNeeded -Encoding utf8BOM -Force;
}
