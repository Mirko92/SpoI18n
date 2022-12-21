# SPO-I18n
A Powershell module to easy handle i18n in SharePoint online sites.

## Introduction 
A useful tool to handle i18n in Sharepoint Online. 

It let you to extract CSV (easy to edit), copy values cross CSV files (DRY) and then create ".*resx" files to upload to Sharepoint Online Site.

## Getting Started

1.	Installation process
  ```
  Import-Module "<PathToModuleFolder>\SpoI18n\SpoI18n.psm1" -Force;
  ```
2.	Software dependencies
  ```
  PnP.Powershell >= 1.11.0
  ```