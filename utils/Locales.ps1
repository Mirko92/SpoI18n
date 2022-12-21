$localesJsonPath = "$PSScriptRoot\..\assets\Locales.json";

function Get-Locales {
  return Get-Content -Path $localesJsonPath | ConvertFrom-Json;
}

function LocaleArgumentCompleter{
  param ( 
    $commandName,
    $parameterName,
    $wordToComplete,
    $commandAst,
    $fakeBoundParameters 
  )

  $possibleValues = Get-Content -Path $localesJsonPath | ConvertFrom-Json;

  $possibleValues = $possibleValues | ForEach-Object { $_.label };

  $possibleValues | Where-Object { $_ -like "$wordToComplete*" };

}

