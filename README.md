# SPO-I18n
A Powershell module to easy handle i18n in SharePoint online sites.

## Introduction 
A useful tool to make easy i18n in Sharepoint Online. 

It lets you handle i18n process, in three simple steps:

1. - Create a CSV file for a site or multiple sites  
  ```Ps1
  # Connect to SPO site, using PnP.Powershell
  Connect-PnPOnline -interactive <url>

  Get-SpoI18nCsv  -outputPath "<path-to-folder>\<file name>.csv" `
                  -locales en-US,it-IT  `
                  -fieldsPattern "Custom_" `
                  -ctGroups "CtG1","CtG2","CtGN" `
                  -lists @(
                    "List to extract 1"
                    "List to extract 2"
                    "List to extract N"
                  );
  ```

2. - If you have many "identical" sites, you can copy translations between them  
```Ps1
Copy-SpoI18nCsv -src        '<path-to-source-file>' `
                -dest       '<path-to-destination-file>' `
                -locale     '<locale-to-copy>' `
                -localeKey  '<locale-to-use-as-key>';

# Add "-replace" param if you want to replace "destination file", 
# otherwise a new file will be generated with timestamp as suffix.
```

3. - Convert CSV file to a Resource File ("*.resx")
```PS1
ConvertFrom-SpoI18nCsv  -fileName "<output-file-name>" `
                        -outputPath "<output-folder-path>" `
                        -src "<file-to-convert-path>";

# By default every locales in the src file will be used to generate a Resx file, 
# if you want to skip one or more locales add localesSkip param.  
# Eg: "-localesToSkip en-US,it-IT"
```


## Getting Started

[Powershell Gallery](https://www.powershellgallery.com/packages/SpoI18n/0.1.0)

1.	Installation process
  ```
  Install-Module -Name SpoI18n;
  ```
2.	Software dependencies
  ```
  PnP.Powershell >= 1.11.0
  ```