<#
.SYNOPSIS
It copies a specific locale from the source file to destination file.

.DESCRIPTION
In order to have matches between source and destination file, 
it composes the keys by: 
 - splitting destination key
 - replace site's specific GUID 
 - looking for the same value in the default locale

Then it uses the keys to get locale value and copies it;

.PARAMETER src
Path of the source file.

.PARAMETER dest
Path of the destination file.

.PARAMETER locale
Locale to copy. 
"Eg: it-IT"

.PARAMETER localeKey
Default Locale. Used as a key, it helps to find match.
"Eg: en-US"

.PARAMETER replace
If set, replace destination file; 
Otherwise a new file will be created, in the same folder, named:
"<DestinationNameFile>_<DateFormat[yyyMMddHHmm]>.csv"

.EXAMPLE
Copy-SpoI18nCsv -src  "<path-to-folder>\<src-filename>.csv" `
                -dest "<path-to-folder>\<dest-filename>.csv" `
                -locale it-IT `
                -localeKey en-US `
                -replace;
#>
function Copy-SpoI18nCsv {
  param (
    [Parameter(Mandatory)]
    [string] $src,

    [Parameter(Mandatory)]
    [string] $dest,

    [Parameter(Mandatory)]
    [ArgumentCompleter({ LocaleArgumentCompleter @args })]
    [string] $locale,

    [Parameter(Mandatory)]
    [ArgumentCompleter({ LocaleArgumentCompleter @args })]
    [string] $localeKey,

    [switch] $replace
  )

  $source      = Import-Csv -Path $src  -Encoding utf8BOM;
  $destination = Import-Csv -Path $dest -Encoding utf8BOM;

  $srcHash  = $source       | Select-Object -Skip 1 | Group-Object Key -AsHashTable -AsString;
  $destHash = $destination  | Select-Object -Skip 1 | Group-Object Key -AsHashTable -AsString;

  # Collection to log "not found keys"
  $notFounds = @();

  foreach ($dKey in $destHash.Keys) {
    $value = "";

    switch -Regex ($dKey) {
      # SITE FIELD / CT
      "^[0]{32}_(FieldTitle|CTName|CTDesc).*$"   
      {
        
        if ( $srcHash.ContainsKey($dKey) ) {
          # This key can be used as is to find value in source file
          $value = $srcHash[$dkey][0]."$locale"
        } else {
          Write-Host "$dkey - not found in source file" -ForegroundColor DarkYellow;
          
          $notFounds += [PSCustomObject]@{
            "Type"      = "Site_Field/CtName/CtDesc"
            "DestKey"   = "$dKey"
            "SourceKey" = "$dkey"
          }
        }
        break;
      }

      # LIST FIELD
      "^[a-z0-9]{32}(?'type'_FieldTitle).*$"       
      {
        $null = $dkey -match "(?'listId'^[a-z0-9]{32})(?'type'_FieldTitle|_CTName|_CTDesc)(?'fieldName'.*)$"   
        $type = $Matches.type; 

        # List title in destination file
        $listTitleKey = $destHash["$($Matches.listId)_ListTitle"].$localeKey;

        # Find source list id 
        $sourceListId = Get-ListId -list $source -title $listTitleKey -key $localeKey;

        if ($sourceListId) {
          $sourceKey = "$($sourceListId)$($type)$($Matches.fieldName)";

          $value = $srcHash[$sourceKey][0]."$locale";
        } 

        break;
      }
      
      # LIST  CTName / _CTDesc
      "^[a-z0-9]{32}(?'type'_CTName|_CTDesc).*$"  {
        $null = $dkey -match "(?'listId'^[a-z0-9]{32})(?'type'_CTName|_CTDesc)(?'listCtId'.*)$";
        $type = $Matches.type; 
        $listCtId = $Matches.listCtId; 

        # List title in destination file
        $listTitleKey = $destHash["$($Matches.listId)_ListTitle"].$localeKey;

        # Find source list id 
        $sourceListId = Get-ListId -list $source -title $listTitleKey -key $localeKey;

        if ($sourceListId) {
          # [ListId][Type][SITE_CT_ID]
          $sourceKey = "$($sourceListId)$($type)$($listCtId.Substring(0, 40))";
  
          $sourceItem = $source | Where-Object {
            $_.key -like "$sourceKey*"
          }
  
          if ($sourceItem -and $sourceItem.Count -eq 1) {
            $value = $sourceItem.$locale;
          } else {
            $notFounds += [PSCustomObject]@{
              "Type"      = "$type"
              "DestKey"   = "$dKey"
              "SourceKey" = "$sourceKey"
            }
          }
        }

        break;
      }
      
      # LIST TITLE 
      "^[a-z0-9]{32}_ListTitle$"          
      {
        $listTitleKey = $destHash[$dkey][0].$localeKey;

        $sourceListId = Get-ListId -list $source -title $listTitleKey -key $localeKey;

        if ($sourceListId) {
          $value = $srcHash["$($sourceListId)_ListTitle"][0]."$locale";
        }

        break;
      }

      # LIST DESC
      "^[a-z0-9]{32}_ListDescription$"    
      {
        $null = $dkey -match "(?'listId'^[a-z0-9]{32})_ListDescription$"   

        # List title in destination file
        $listTitleKey = $destHash["$($Matches.listId)_ListTitle"].$localeKey;

        # Find source list id 
        $sourceListId = Get-ListId -list $source -title $listTitleKey -key $localeKey;
        
        if ($sourceListId) {
          $sourceKey = "$($sourceListId)_ListDescription";
  
          $value = $srcHash[$sourceKey][0]."$locale";
        }

        break;
      }

      # VIEW TITLE 
      "^[a-z0-9]{32}_ViewTitle\{.*\}$"    
      {
        $null = $dkey -match "(?'listId'^[a-z0-9]{32})_ViewTitle.*$" 

        # List title in destination file
        $listTitleKey = $destHash["$($Matches.listId)_ListTitle"].$localeKey;

        # Find source list id 
        $sourceListId = Get-ListId -list $source -title $listTitleKey -key $localeKey;

        if ($sourceListId) {
          $sourceKey = "$($sourceListId)_ViewTitle"
  
          $notFounds += [PSCustomObject]@{
            "Type"      = "_ViewTitle"
            "DestKey"   = "$dKey"
            "SourceKey" = "$sourceKey"
          }
        }

        break;
      }
    }

    if ($value) {
      # Copy source value to destination 
      $destHash[$dkey][0]."$locale" = $value;
    }
  }

  if ($replace) {
    $destination | Export-Csv -Path $dest -Force -Encoding utf8BOM;
  } else {
    $parentFolder = Split-Path $dest -Parent;
    $fileName     = Split-Path $dest -LeafBase;
    $suffix       = Get-Date -Format "yyyMMddHHmm";

    $destination | Export-Csv -Path "$parentFolder/$($fileName)_$suffix.csv";
  }

  if ($notFounds.Count -gt 0) {
    Write-Host @"
--------------------------------------------------------
I'm sorry, I can't find any matches for these keys.
I almost did it all, be grateful.

If you can do better, feel free to make a pull-request. 
--------------------------------------------------------
"@ `
      -ForegroundColor Magenta;

    return $notFounds
  }
}

function Get-ListId {
  param ( 
    [Parameter(Mandatory)]
    [object[]] $list,

    [Parameter(Mandatory)]
    [string] $title,

    [Parameter(Mandatory)]
    [string] $key
  )

  $listItem = $list | Where-Object { 
    ($_.key -like "*_ListTitle") -and 
    ($_.$key -eq $title)
  };

  if ($listItem) {
    return $listItem.Key.Replace("_ListTitle", "");
  } else {
    return $null;
  }
}