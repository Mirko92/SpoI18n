<#
.SYNOPSIS
Extract a CSV for ContentTypes, Fields, Lists and Views of a SPO site.

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

.PARAMETER fieldsPattern
It allows you to restrict the Fields number to translate;
Don't use wildcards, they will be added automatically at the begin and the end of pattern.
eg: "CUSTOM_"

.PARAMETER ctGroups
It allows you to restrict the ContentTypes number to translate.
eg: "Custom content types"

.PARAMETER noCtGRoups
It allows you to exclude ContentTypes;

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

    [string[]] $lists,
    
    [string] $fieldsPattern,

    [switch] $includeListViews,

    [switch] $noCtGroups
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

  $fieldCounter = 0;
  foreach ($field in $siteFields) {
    Write-Progress  -PercentComplete (++$fieldCounter / $siteFields.Count  * 100) `
                    -Activity "Processing Field: $($field.Title)" `
                    -Status  "Processing Field $($fieldCounter) of $($siteFields.Count)" `
                    -Completed:($siteFields.Count -eq $fieldCounter)


    $csvWriter.AddRow(
      "00000000000000000000000000000000_FieldTitle$($field.InternalName)", 
      $field.Title
    );
  }
  #endregion

  #region CONTENT TYPES  
  if (!$noCtGroups) {
    $siteCTS = if ($ctGroups.Count -gt 0) {
      (Get-PnPContentType | Where-Object Group -in $ctGroups)
    } else { 
      Get-PnPContentType;
    }
    $siteCTS = $siteCTS | Sort-Object Name;
  
    Write-Host "Found #$($siteCTS.Count) Content types";
  
    $ctCounter = 0;
    foreach ($ct in $siteCTS) {
      Write-Progress  -PercentComplete (++$ctCounter / $siteCTS.Count  * 100) `
                      -Activity "Processing CT: $($ct.Name)" `
                      -Status  "Processing CT $($ctCounter) of $($siteCTS.Count)";
  
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
  Write-Host "------------------------------------------------";

  $listCounter = 0;
  foreach ($list in $siteLists) {
    Write-Host "Processing list: $($list.Title)";
    Write-Progress  -PercentComplete (++$listCounter / $siteLists.Count  * 100) `
                    -Activity "Processing list: $($list.Title)" `
                    -Status  "Processing list $($listCounter) of $($siteLists.Count)" `
                    -Id 100;

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

    $ctListCounter = 0;
    foreach ($listCT in $listCTS) {
      Write-Progress  -PercentComplete (++$ctListCounter / $listCTS.Count  * 100) `
                      -Activity "Processing CT: $($listCT.Name)" `
                      -Status  "Processing CT $($ctListCounter) of $($listCTS.Count)" `
                      -ParentId 100 `
                      -Id 200;

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

    $listFieldsCounter = 0;
    foreach ($listField in $listFields) {
      Write-Progress  -PercentComplete (++$listFieldsCounter / $listFields.Count  * 100) `
                      -Activity "Processing field: $($listField.Title)" `
                      -Status  "Processing field $($listFieldsCounter) of $($listFields.Count)" `
                      -ParentId 100 `
                      -Id 300;

      $csvWriter.AddRow(
        "$($listKey)_FieldTitle$($listField.InternalName)", 
        $listField.Title
      );
    }
    #endregion

    #region VIEWS of the list
    if ($includeListViews) {
      $listViews = Get-PnPView -List $listID | Sort-Object Title;

      $listViewsCounter = 0;
      foreach ($listView in $listViews) {
        Write-Progress  -PercentComplete (++$listViewsCounter / $listViews.Count  * 100) `
                        -Activity "Processing View: $($listView.Title)" `
                        -Status  "Processing View $($listViewsCounter) of $($listViews.Count)" `
                        -ParentId 100 `
                        -Id 400;
      
        $csvWriter.AddRow(
          "$($listKey)_ViewTitle{$($listView.Id.ToString().ToUpper())}", 
          $listView.Title
        );
      }
    }
    #endregion

    
    Write-Host "------------------------------------------------";
  }

  $parentFolderPath = Split-Path $outputPath -Parent;
  if (!(Test-Path $parentFolderPath)) {
    New-Item $parentFolderPath -ItemType Directory
  }

  $csvResult = $csvWriter.csvResult;

  $csvResult | Export-Csv -Path "$outputPath" -UseQuotes AsNeeded -Encoding utf8BOM -Force;
}
