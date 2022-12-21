class SpoI18nCsvWriter {
  [array]     $localesInfo;
  [string[]]  $locales;
  $csvResult = @();

  SpoI18nCsvWriter([array] $localesInfo) {
    $this.localesInfo = $localesInfo;
    $this.locales     = ($localesInfo | ForEach-Object { $_.label });
  }

  [void] AddHeader() {
    $this.csvResult += $this.GetHeader($this.localesInfo);
  }

  [void] AddRow(
    [string] $key,
    [string] $value,
    [boolean] $isMultiline = $false
  ) {
    $this.csvResult += $this.NewRow($key, $value, $isMultiline);
  }

  [void] AddRow(
    [string] $key,
    [string] $value
  ) {
    $this.csvResult += $this.NewRow($key, $value, $false);
  }

  [PSCustomObject] GetHeader(
    [PSCustomObject[]] $locales
  ) {
  
    $header = [ordered]@{
      "Key" = "ExportedLanguage"
    };
    
    foreach ($locale in $locales) {
      $lang = $locale.label;
      $code = $locale.code;
  
      $commentKey = "Comment.$lang";
      
      $header[$lang]       = $code;
      $header[$commentKey] = "$commentKey";
    }
  
    return [PSCustomObject]$header;
  }

  [PSCustomObject] NewRow(
    [string]    $key,
    [string]    $value,
    [bool]      $isMultiline
  ) {
    $comment = $isMultiline ? "Multiple lines of text" : "Single line of text";
  
    $local:result = [ordered]@{
      "Key" = $key
    };
  
    foreach ($locale in $this.locales) {
      $commentKey = "Comment.$locale";
  
      $local:result[$commentKey] = $comment;
      $local:result[$locale]     = $value;
    }
  
    return [PSCustomObject]$local:result;
  }

}