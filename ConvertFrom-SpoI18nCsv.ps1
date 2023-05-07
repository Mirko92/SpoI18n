<#
.SYNOPSIS
It converts a CSV file to "*.resx" files that fulfills SPO site requirements.

.DESCRIPTION
It create a resx file for each locale column in the CSV.
A resulting file name will be:
"<fileName>.<locale>.resx"
Eg:
"PrefixProvided.it-IT.resx"

.PARAMETER fileName
Output file prefix name. 

.PARAMETER src
Path of the CSV file.

.PARAMETER outputPath
Destination folder

.PARAMETER delimiter
Choose the csv delimiter based on the src file delimiter

.EXAMPLE
ConvertFrom-SpoI18nCsv  -src "C:/Folder/File.csv" `
                        -fileName "MyResxFile" `
                        -outputPath "C:/OutputFolder";
#>
function ConvertFrom-SpoI18nCsv {
  param (
    [Parameter(Mandatory)]
    [string] $fileName,

    [Parameter(Mandatory)]
    [string] $src,

    [string] $outputPath = ".",
    
    [ArgumentCompleter({ LocaleArgumentCompleter @args })]
    [string[]] $localesToSkip,

    [string] $delimiter = ","
  )

  $template = "`t<data name=`"####KEY####`" xml:space=`"preserve`">" +
  "`n`t`t<value>####VALUE####</value>" +
  "`n`t`t<comment>####COMMENT####</comment>" +
  "`n`t</data>";

  $fileSeedPath = "$PSScriptRoot\assets\_seed.resx";
  $fileSeed     = Get-Content -Path $fileSeedPath;

  $source = Import-Csv -Path $src -Encoding utf8BOM -Delimiter $delimiter;

  if ($source.Count -le 0) {
    throw "Src file is empty!"
  }

  # Collect every locale property like it-IT
  $locales = $source[0]                   | 
    Get-Member    -MemberType Properties  | 
    Select-Object -ExpandProperty Name    | 
    Where-Object { 
      $_ -match "^[A-Za-z]{2,4}([_-][A-Za-z]{4})?([_-]([A-Za-z]{2}|[0-9]{3}))$" 
    }                                     |
    ForEach-Object {
      @{  "label"= $_; "code"= $source[0].$_; }
    };

  # Exclude locales to skip
  if ($localesToSkip -gt 0) {
    $locales = $locales | Where-Object { $_.label -notin $localesToSkip };
  }

  # Hashtable key: locale.label, value: content of resx file 
  $result = @{};
  foreach ($row in ($source | Select-Object -Skip 1)) {

    foreach($locale in $locales) {
      $xmlRow = $template.Replace("####KEY####",     $row.Key                       );
      $xmlRow =   $xmlRow.Replace("####VALUE####",   $row."$($locale.label)"        );
      $xmlRow =   $xmlRow.Replace("####COMMENT####", $row."Comment.$($locale.label)");
      
      $result[$locale.label] += $xmlRow;
    }
  } 

  # Create a file for each listed locale
  foreach($locale in $locales) {
    $newFile = $fileSeed.Clone();
    $newFile = $newFile.Replace("####LANGUAGE####",     $locale.code          );
    $newFile = $newFile.Replace("####CONTENT-HERE####", $result[$locale.label]);
  
    if (!(Test-Path $outputPath)) {
      New-Item $outputPath -ItemType Directory
    }
  
    Out-File  -FilePath "$outputPath\$fileName.$($locale.label).resx" `
              -InputObject $newFile `
              -Force;
  }
}