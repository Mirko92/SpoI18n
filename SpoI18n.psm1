. $PSScriptRoot\utils\Locales.ps1;
. $PSScriptRoot\utils\SPO.ps1;
. $PSScriptRoot\SpoI18nCsvWriter.ps1


. $PSScriptRoot\Get-SpoI18nCsv.ps1;
. $PSScriptRoot\ConvertFrom-SpoI18nCsv.ps1;
. $PSScriptRoot\Copy-SpoI18nCsv.ps1;

Export-ModuleMember -Function Get-SpoI18nCsv, ConvertFrom-SpoI18nCsv, Copy-SpoI18nCsv, LocaleArgumentCompleter ;

$localesJsonPath = "$PSScriptRoot\assets\Locales.json";

$scriptblock = {
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

Register-ArgumentCompleter -CommandName Get-SpoI18nCsv          -ParameterName Locales       -ScriptBlock $scriptBlock;
Register-ArgumentCompleter -CommandName ConvertFrom-SpoI18nCsv  -ParameterName LocalesToSkip -ScriptBlock $scriptBlock;
